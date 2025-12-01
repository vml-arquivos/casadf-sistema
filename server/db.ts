import { eq, desc, and, or, like, gte, lte, sql } from "drizzle-orm";
import { drizzle } from "drizzle-orm/mysql2";
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
import { ENV } from './_core/env';

let _db: ReturnType<typeof drizzle> | null = null;

// Lazily create the drizzle instance so local tooling can run without a DB.
export async function getDb() {
  if (!_db && process.env.DATABASE_URL) {
    try {
      _db = drizzle(process.env.DATABASE_URL);
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

    await db.insert(users).values(values).onDuplicateKeyUpdate({
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

  const result = await db.insert(properties).values(property);
  const insertId = Number(result[0].insertId);
  const created = await getPropertyById(insertId);
  return created!;
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
// LEAD FUNCTIONS
// ============================================

export async function createLead(lead: InsertLead) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(leads).values(lead);
  const insertId = Number(result[0].insertId);
  const created = await getLeadById(insertId);
  return created!;
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

  const result = await db.insert(interactions).values(interaction);
  const insertId = Number(result[0].insertId);
  const created = await db.select().from(interactions).where(eq(interactions.id, insertId)).limit(1);
  return created[0]!;
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

  const result = await db.insert(blogPosts).values(post);
  const insertId = Number(result[0].insertId);
  const created = await getBlogPostById(insertId);
  return created!;
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

export async function getAllBlogPosts(filters?: {
  published?: boolean;
  categoryId?: number;
}) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  let query = db.select().from(blogPosts);
  const conditions: any[] = [];

  if (filters) {
    if (filters.published !== undefined) conditions.push(eq(blogPosts.published, filters.published));
    if (filters.categoryId) conditions.push(eq(blogPosts.categoryId, filters.categoryId));
  }

  if (conditions.length > 0) {
    query = query.where(and(...conditions)) as any;
  }

  const result = await query.orderBy(desc(blogPosts.publishedAt));
  return result;
}

export async function getPublishedBlogPosts(limit?: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  let query = db
    .select()
    .from(blogPosts)
    .where(eq(blogPosts.published, true))
    .orderBy(desc(blogPosts.publishedAt));

  if (limit) {
    query = query.limit(limit) as any;
  }

  return await query;
}

// ============================================
// BLOG CATEGORY FUNCTIONS
// ============================================

export async function createBlogCategory(category: InsertBlogCategory) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(blogCategories).values(category);
  const insertId = Number(result[0].insertId);
  const created = await db.select().from(blogCategories).where(eq(blogCategories.id, insertId)).limit(1);
  return created[0]!;
}

export async function getAllBlogCategories() {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.select().from(blogCategories).orderBy(blogCategories.name);
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
// PROPERTY IMAGES FUNCTIONS
// ============================================

export async function createPropertyImage(image: InsertPropertyImage) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(propertyImages).values(image);
  const insertId = Number(result[0].insertId);
  const created = await db.select().from(propertyImages).where(eq(propertyImages.id, insertId)).limit(1);
  return created[0]!;
}

export async function getPropertyImages(propertyId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db
    .select()
    .from(propertyImages)
    .where(eq(propertyImages.propertyId, propertyId))
    .orderBy(desc(propertyImages.isPrimary), propertyImages.displayOrder);
  
  return result;
}

export async function deletePropertyImage(imageId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.delete(propertyImages).where(eq(propertyImages.id, imageId));
}

export async function setPrimaryImage(imageId: number, propertyId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  // Remove primary flag from all images of this property
  await db
    .update(propertyImages)
    .set({ isPrimary: 0 })
    .where(eq(propertyImages.propertyId, propertyId));

  // Set the new primary image
  await db
    .update(propertyImages)
    .set({ isPrimary: 1 })
    .where(eq(propertyImages.id, imageId));
}

export async function updateImageOrder(imageId: number, displayOrder: number) {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db
    .update(propertyImages)
    .set({ displayOrder })
    .where(eq(propertyImages.id, imageId));
}


// ============================================
// INTEGRATION FUNCTIONS (WhatsApp / N8N)
// ============================================

// Message Buffer
export async function createMessageBuffer(data: InsertMessageBuffer): Promise<MessageBuffer> {
  const db = await getDb();
  if (!db) throw new Error("Database not available");
  
  const result = await db.insert(messageBuffer).values(data);
  const inserted = await db.select().from(messageBuffer).where(eq(messageBuffer.id, Number(result[0].insertId))).limit(1);
  return inserted[0]!;
}

export async function getMessagesByPhone(phone: string): Promise<MessageBuffer[]> {
  const db = await getDb();
  if (!db) return [];
  
  return db.select().from(messageBuffer).where(eq(messageBuffer.phone, phone)).orderBy(desc(messageBuffer.timestamp));
}

export async function markMessageProcessed(messageId: string): Promise<void> {
  const db = await getDb();
  if (!db) return;
  
  await db.update(messageBuffer).set({ processed: 1 }).where(eq(messageBuffer.messageId, messageId));
}

// AI Context / History
export async function saveAiContext(data: InsertAiContextStatus): Promise<AiContextStatus> {
  const db = await getDb();
  if (!db) throw new Error("Database not available");
  
  const result = await db.insert(aiContextStatus).values(data);
  const inserted = await db.select().from(aiContextStatus).where(eq(aiContextStatus.id, Number(result[0].insertId))).limit(1);
  return inserted[0]!;
}

export async function getAiHistoryBySession(sessionId: string): Promise<AiContextStatus[]> {
  const db = await getDb();
  if (!db) return [];
  
  return db.select().from(aiContextStatus).where(eq(aiContextStatus.sessionId, sessionId)).orderBy(desc(aiContextStatus.createdAt));
}

export async function getAiHistoryByPhone(phone: string, limit: number = 50): Promise<AiContextStatus[]> {
  const db = await getDb();
  if (!db) return [];
  
  const results = await db.select().from(aiContextStatus).where(eq(aiContextStatus.phone, phone)).orderBy(desc(aiContextStatus.createdAt)).limit(limit);
  return results;
}

// Client Interests
export async function createClientInterest(data: InsertClientInterest): Promise<ClientInterest> {
  const db = await getDb();
  if (!db) throw new Error("Database not available");
  
  const result = await db.insert(clientInterests).values(data);
  const inserted = await db.select().from(clientInterests).where(eq(clientInterests.id, Number(result[0].insertId))).limit(1);
  return inserted[0]!;
}

export async function getClientInterests(clientId: number): Promise<ClientInterest[]> {
  const db = await getDb();
  if (!db) return [];
  
  return db.select().from(clientInterests).where(eq(clientInterests.clientId, clientId)).orderBy(desc(clientInterests.createdAt));
}

export async function updateClientInterest(id: number, data: Partial<InsertClientInterest>): Promise<void> {
  const db = await getDb();
  if (!db) return;
  
  await db.update(clientInterests).set(data).where(eq(clientInterests.id, id));
}

// Webhook Logs
export async function createWebhookLog(data: InsertWebhookLog): Promise<WebhookLog> {
  const db = await getDb();
  if (!db) throw new Error("Database not available");
  
  const result = await db.insert(webhookLogs).values(data);
  const inserted = await db.select().from(webhookLogs).where(eq(webhookLogs.id, Number(result[0].insertId))).limit(1);
  return inserted[0]!;
}

export async function getWebhookLogs(limit: number = 100): Promise<WebhookLog[]> {
  const db = await getDb();
  if (!db) return [];
  
  return db.select().from(webhookLogs).orderBy(desc(webhookLogs.createdAt)).limit(limit);
}

// Helper: Upsert lead from WhatsApp (N8N integration)
export async function upsertLeadFromWhatsApp(data: {
  name: string;
  phone: string;
  email?: string;
  message?: string;
  propertyInterest?: string;
  budgetRange?: string;
}): Promise<Lead> {
  const db = await getDb();
  if (!db) throw new Error("Database not available");
  
  // Buscar lead existente por telefone
  const existing = await db.select().from(leads).where(eq(leads.phone, data.phone)).limit(1);
  
  if (existing.length > 0) {
    // Atualizar lead existente
    const leadId = existing[0]!.id;
    await db.update(leads).set({
      name: data.name,
      email: data.email || existing[0]!.email,
      notes: data.message ? `${existing[0]!.notes || ''}\n\n[WhatsApp] ${data.message}` : existing[0]!.notes,
      source: "whatsapp",
      updatedAt: new Date(),
    }).where(eq(leads.id, leadId));
    
    const updated = await db.select().from(leads).where(eq(leads.id, leadId)).limit(1);
    return updated[0]!;
  } else {
    // Criar novo lead
    const newLead: InsertLead = {
      name: data.name,
      phone: data.phone,
      email: data.email,
      stage: "novo",
      source: "whatsapp",
      qualification: "nao_qualificado",
      clientType: "comprador",
      preferredPropertyTypes: data.propertyInterest ? JSON.stringify([data.propertyInterest]) : null,
      notes: data.budgetRange ? `Orçamento: ${data.budgetRange}\n${data.message || ''}` : data.message,
    };
    
    const result = await db.insert(leads).values(newLead);
    const inserted = await db.select().from(leads).where(eq(leads.id, Number(result[0].insertId))).limit(1);
    return inserted[0]!;
  }
}

// ============================================
// OWNERS FUNCTIONS
// ============================================

export async function createOwner(owner: InsertOwner): Promise<Owner> {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  const result = await db.insert(owners).values(owner);
  const insertId = Number(result[0].insertId);
  const created = await db.select().from(owners).where(eq(owners.id, insertId)).limit(1);
  return created[0]!;
}

export async function getAllOwners(): Promise<Owner[]> {
  const db = await getDb();
  if (!db) return [];

  return db.select().from(owners).orderBy(desc(owners.createdAt));
}

export async function getOwnerById(id: number): Promise<Owner | null> {
  const db = await getDb();
  if (!db) return null;

  const result = await db.select().from(owners).where(eq(owners.id, id)).limit(1);
  return result.length > 0 ? result[0] : null;
}

export async function updateOwner(id: number, data: Partial<InsertOwner>): Promise<void> {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.update(owners).set(data).where(eq(owners.id, id));
}

export async function deleteOwner(id: number): Promise<void> {
  const db = await getDb();
  if (!db) throw new Error("Database not available");

  await db.delete(owners).where(eq(owners.id, id));
}

export async function searchOwners(query: string): Promise<Owner[]> {
  const db = await getDb();
  if (!db) return [];

  return db
    .select()
    .from(owners)
    .where(
      or(
        like(owners.name, `%${query}%`),
        like(owners.email, `%${query}%`),
        like(owners.phone, `%${query}%`),
        like(owners.cpfCnpj, `%${query}%`)
      )
    )
    .orderBy(desc(owners.createdAt));
}
