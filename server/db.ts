import { eq, desc, and, or, like, gte, lte, sql } from "drizzle-orm";
import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";
import { 
  InsertUser, 
  users, 
  properties, 
  propertyImages,
  leads, 
  interactions, 
  blogPosts, 
  blogCategories,
  siteSettings,
  messageBuffer,
  aiContextStatus,
  clientInterests,
  webhookLogs,
  owners,
  analyticsEvents,
  campaignSources,
  transactions,
  commissions,
  reviews,
  type Property,
  type PropertyImage,
  type Lead,
  type Interaction,
  type BlogPost,
  type BlogCategory,
  type SiteSetting,
  type MessageBuffer,
  type AiContextStatus,
  type ClientInterest,
  type WebhookLog,
  type Owner,
  type InsertProperty,
  type InsertPropertyImage,
  type InsertLead,
  type InsertInteraction,
  type InsertBlogPost,
  type InsertBlogCategory,
  type InsertSiteSetting,
  type InsertMessageBuffer,
  type InsertAiContextStatus,
  type InsertClientInterest,
  type InsertWebhookLog,
  type InsertOwner,
  type AnalyticsEvent,
  type CampaignSource,
  type Transaction,
  type Commission,
  type Review,
  type InsertAnalyticsEvent,
  type InsertCampaignSource,
  type InsertTransaction,
  type InsertCommission,
  type InsertReview
} from "../drizzle/schema";
import * as schema from "../drizzle/schema";
import { ENV } from './_core/env';

let _db: ReturnType<typeof drizzle> | null = null;
let _pool: Pool | null = null;

// Lazily create the drizzle instance so local tooling can run without a DB.
export async function getDb() {
  if (!_db && process.env.DATABASE_URL) {
    try {
      if (!_pool) {
        _pool = new Pool({ connectionString: process.env.DATABASE_URL });
      }
      _db = drizzle(_pool, { schema });
    } catch (error) {
      console.warn("[Database] Failed to connect:", error);
      _db = null;
    }
  }
  return _db;
}

// ============================================
// USER FUNCTIONS
// ============================================

export async function upsertUser(user: InsertUser): Promise<void> {
  if (!user.openId) {
    throw new Error("User openId is required for upsert");
  }

  const db = await getDb();
  if (!db) {
    console.warn("[Database] Cannot upsert user: database not available");
    return;
  }

  try {
    const values: InsertUser = {
      openId: user.openId,
    };
    const updateSet: Record<string, unknown> = {};

    const textFields = ["name", "email", "loginMethod"] as const;
    type TextField = (typeof textFields)[number];

    const assignNullable = (field: TextField) => {
      const value = user[field];
      if (value === undefined) return;
      const normalized = value ?? null;
      values[field] = normalized;
      updateSet[field] = normalized;
    };

    textFields.forEach(assignNullable);

    if (user.lastSignedIn !== undefined) {
      values.lastSignedIn = user.lastSignedIn;
      updateSet.lastSignedIn = user.lastSignedIn;
    }
    if (user.role !== undefined) {
      values.role = user.role;
      updateSet.role = user.role;
    } else if (user.openId === ENV.ownerOpenId) {
      values.role = 'admin';
      updateSet.role = 'admin';
    }

    if (!values.lastSignedIn) {
      values.lastSignedIn = new Date();
    }

    if (Object.keys(updateSet).length === 0) {
      updateSet.lastSignedIn = new Date();
    }

    // PostgreSQL usa onConflictDoUpdate ao invés de onDuplicateKeyUpdate
    await db.insert(users).values(values).onConflictDoUpdate({
      target: users.openId,
      set: updateSet,
    });
  } catch (error) {
    console.error("[Database] Failed to upsert user:", error);
    throw error;
  }
}

export async function getUserByOpenId(openId: string) {
  const db = await getDb();
  if (!db) {
    console.warn("[Database] Cannot get user: database not available");
    return undefined;
  }

  const result = await db.select().from(users).where(eq(users.openId, openId)).limit(1);

  return result.length > 0 ? result[0] : undefined;
}

// ============================================
// PROPERTY FUNCTIONS
// ============================================

export async function createProperty(property: InsertProperty) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(properties).values(property).returning();
  return result[0];
}

export async function updateProperty(id: number, property: Partial<InsertProperty>) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.update(properties).set(property).where(eq(properties.id, id));
}

export async function deleteProperty(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.delete(properties).where(eq(properties.id, id));
}

export async function getPropertyById(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.select().from(properties).where(eq(properties.id, id)).limit(1);
  return result.length > 0 ? result[0] : null;
}

export async function getAllProperties(filters?: {
  status?: string;
  transactionType?: string;
  propertyType?: string;
  neighborhood?: string;
  minPrice?: number;
  maxPrice?: number;
  minArea?: number;
  maxArea?: number;
  bedrooms?: number;
  bathrooms?: number;
}) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  let query = db.select().from(properties);
  const conditions: any[] = [];

  if (filters) {
    if (filters.status) conditions.push(eq(properties.status, filters.status as any));
    if (filters.transactionType) conditions.push(eq(properties.transactionType, filters.transactionType as any));
    if (filters.propertyType) conditions.push(eq(properties.propertyType, filters.propertyType as any));
    if (filters.neighborhood) conditions.push(like(properties.neighborhood, `%${filters.neighborhood}%`));
    if (filters.minPrice) conditions.push(gte(properties.salePrice, filters.minPrice));
    if (filters.maxPrice) conditions.push(lte(properties.salePrice, filters.maxPrice));
    if (filters.minArea) conditions.push(gte(properties.totalArea, filters.minArea));
    if (filters.maxArea) conditions.push(lte(properties.totalArea, filters.maxArea));
    if (filters.bedrooms) conditions.push(eq(properties.bedrooms, filters.bedrooms));
    if (filters.bathrooms) conditions.push(eq(properties.bathrooms, filters.bathrooms));
  }

  if (conditions.length > 0) {
    query = query.where(and(...conditions)) as any;
  }

  const result = await query.orderBy(desc(properties.createdAt));
  return result;
}

export async function getFeaturedProperties(limit: number = 6) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(properties)
    .where(eq(properties.featured, true))
    .orderBy(desc(properties.createdAt))
    .limit(limit);

  return result;
}

// ============================================
// PROPERTY IMAGE FUNCTIONS
// ============================================

export async function createPropertyImage(image: InsertPropertyImage) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(propertyImages).values(image).returning();
  return result[0];
}

export async function getPropertyImages(propertyId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(propertyImages)
    .where(eq(propertyImages.propertyId, propertyId))
    .orderBy(desc(propertyImages.displayOrder));

  return result;
}

export async function deletePropertyImage(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.delete(propertyImages).where(eq(propertyImages.id, id));
}

// ============================================
// LEAD FUNCTIONS
// ============================================

export async function createLead(lead: InsertLead) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(leads).values(lead).returning();
  return result[0];
}

export async function updateLead(id: number, lead: Partial<InsertLead>) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.update(leads).set(lead).where(eq(leads.id, id));
}

export async function deleteLead(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.delete(leads).where(eq(leads.id, id));
}

export async function getLeadById(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.select().from(leads).where(eq(leads.id, id)).limit(1);
  return result.length > 0 ? result[0] : null;
}

export async function getAllLeads(filters?: {
  stage?: string;
  source?: string;
  assignedTo?: number;
}) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  let query = db.select().from(leads);
  const conditions: any[] = [];

  if (filters) {
    if (filters.stage) conditions.push(eq(leads.stage, filters.stage as any));
    if (filters.source) conditions.push(eq(leads.source, filters.source as any));
    if (filters.assignedTo) conditions.push(eq(leads.assignedTo, filters.assignedTo));
  }

  if (conditions.length > 0) {
    query = query.where(and(...conditions)) as any;
  }

  const result = await query.orderBy(desc(leads.createdAt));
  return result;
}

export async function getLeadsByStage(stage: string) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(leads)
    .where(eq(leads.stage, stage as any))
    .orderBy(desc(leads.createdAt));

  return result;
}

// ============================================
// INTERACTION FUNCTIONS
// ============================================

export async function createInteraction(interaction: InsertInteraction) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(interactions).values(interaction).returning();
  return result[0];
}

export async function getInteractionsByLeadId(leadId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(interactions)
    .where(eq(interactions.leadId, leadId))
    .orderBy(desc(interactions.createdAt));

  return result;
}

export async function getInteractionsByUserId(userId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(interactions)
    .where(eq(interactions.userId, userId))
    .orderBy(desc(interactions.createdAt));

  return result;
}

// ============================================
// BLOG FUNCTIONS
// ============================================

export async function createBlogPost(post: InsertBlogPost) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(blogPosts).values(post).returning();
  return result[0];
}

export async function updateBlogPost(id: number, post: Partial<InsertBlogPost>) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.update(blogPosts).set(post).where(eq(blogPosts.id, id));
}

export async function deleteBlogPost(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.delete(blogPosts).where(eq(blogPosts.id, id));
}

export async function getBlogPostById(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.select().from(blogPosts).where(eq(blogPosts.id, id)).limit(1);
  return result.length > 0 ? result[0] : null;
}

export async function getBlogPostBySlug(slug: string) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.select().from(blogPosts).where(eq(blogPosts.slug, slug)).limit(1);
  return result.length > 0 ? result[0] : null;
}

export async function getAllBlogPosts(published: boolean = true) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(blogPosts)
    .where(eq(blogPosts.published, published))
    .orderBy(desc(blogPosts.createdAt));

  return result;
}

// ============================================
// OWNER FUNCTIONS
// ============================================

export async function createOwner(owner: InsertOwner) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(owners).values(owner).returning();
  return result[0];
}

export async function updateOwner(id: number, owner: Partial<InsertOwner>) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.update(owners).set(owner).where(eq(owners.id, id));
}

export async function deleteOwner(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.delete(owners).where(eq(owners.id, id));
}

export async function getOwnerById(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.select().from(owners).where(eq(owners.id, id)).limit(1);
  return result.length > 0 ? result[0] : null;
}

export async function getAllOwners(activeOnly: boolean = true) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  let query = db.select().from(owners);

  if (activeOnly) {
    query = query.where(eq(owners.active, true)) as any;
  }

  const result = await query.orderBy(desc(owners.createdAt));
  return result;
}

// ============================================
// SITE SETTINGS FUNCTIONS
// ============================================

export async function getSiteSettings() {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.select().from(siteSettings).limit(1);
  return result.length > 0 ? result[0] : null;
}

export async function updateSiteSettings(settings: Partial<InsertSiteSetting>) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const existing = await getSiteSettings();
  
  if (existing) {
    await db.update(siteSettings).set(settings).where(eq(siteSettings.id, existing.id));
  } else {
    await db.insert(siteSettings).values(settings as InsertSiteSetting);
  }
}

// ============================================
// REVIEW FUNCTIONS
// ============================================

export async function createReview(review: InsertReview) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(reviews).values(review).returning();
  return result[0];
}

export async function updateReview(id: number, review: Partial<InsertReview>) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.update(reviews).set(review).where(eq(reviews.id, id));
}

export async function deleteReview(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.delete(reviews).where(eq(reviews.id, id));
}

export async function getReviewById(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.select().from(reviews).where(eq(reviews.id, id)).limit(1);
  return result.length > 0 ? result[0] : null;
}

export async function getAllReviews(approvedOnly: boolean = true) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  let query = db.select().from(reviews);

  if (approvedOnly) {
    query = query.where(eq(reviews.approved, true)) as any;
  }

  const result = await query.orderBy(desc(reviews.createdAt));
  return result;
}

export async function getFeaturedReviews(limit: number = 6) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(reviews)
    .where(and(eq(reviews.approved, true), eq(reviews.featured, true)))
    .orderBy(desc(reviews.displayOrder))
    .limit(limit);

  return result;
}

// ============================================
// ANALYTICS FUNCTIONS
// ============================================

export async function createAnalyticsEvent(event: InsertAnalyticsEvent) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(analyticsEvents).values(event).returning();
  return result[0];
}

export async function getAnalyticsEvents(filters?: {
  eventType?: string;
  propertyId?: number;
  startDate?: Date;
  endDate?: Date;
}) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  let query = db.select().from(analyticsEvents);
  const conditions: any[] = [];

  if (filters) {
    if (filters.eventType) conditions.push(eq(analyticsEvents.eventType, filters.eventType));
    if (filters.propertyId) conditions.push(eq(analyticsEvents.propertyId, filters.propertyId));
    if (filters.startDate) conditions.push(gte(analyticsEvents.createdAt, filters.startDate));
    if (filters.endDate) conditions.push(lte(analyticsEvents.createdAt, filters.endDate));
  }

  if (conditions.length > 0) {
    query = query.where(and(...conditions)) as any;
  }

  const result = await query.orderBy(desc(analyticsEvents.createdAt));
  return result;
}

// ============================================
// WEBHOOK FUNCTIONS
// ============================================

export async function createWebhookLog(log: InsertWebhookLog) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(webhookLogs).values(log).returning();
  return result[0];
}

export async function getWebhookLogs(limit: number = 100) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(webhookLogs)
    .orderBy(desc(webhookLogs.createdAt))
    .limit(limit);

  return result;
}

// ============================================
// AI CONTEXT FUNCTIONS
// ============================================

export async function createAiContext(context: InsertAiContextStatus) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(aiContextStatus).values(context).returning();
  return result[0];
}

export async function getAiContextBySession(sessionId: string, limit: number = 50) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(aiContextStatus)
    .where(eq(aiContextStatus.sessionId, sessionId))
    .orderBy(desc(aiContextStatus.createdAt))
    .limit(limit);

  return result.reverse(); // Retorna em ordem cronológica
}

// ============================================
// MESSAGE BUFFER FUNCTIONS
// ============================================

export async function createMessageBuffer(message: InsertMessageBuffer) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(messageBuffer).values(message).returning();
  return result[0];
}

export async function getUnprocessedMessages(limit: number = 100) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(messageBuffer)
    .where(eq(messageBuffer.processed, 0))
    .orderBy(desc(messageBuffer.createdAt))
    .limit(limit);

  return result;
}

export async function markMessageAsProcessed(id: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.update(messageBuffer).set({ processed: 1 }).where(eq(messageBuffer.id, id));
}
