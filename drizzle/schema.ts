import { pgTable, serial, varchar, text, timestamp, integer, boolean, decimal, jsonb, date, pgEnum } from "drizzle-orm/pg-core";

/**
 * Schema completo para o sistema CasaDF
 * Migrado de MySQL para PostgreSQL
 * Inclui: usuários, imóveis, leads, interações, blog, configurações
 */

// ============================================
// ENUMS
// ============================================

export const roleEnum = pgEnum("role", ["user", "admin"]);
export const propertyTypeEnum = pgEnum("property_type", ["casa", "apartamento", "cobertura", "terreno", "comercial", "rural", "lancamento"]);
export const transactionTypeEnum = pgEnum("transaction_type", ["venda", "locacao", "ambos"]);
export const propertyStatusEnum = pgEnum("property_status", ["disponivel", "reservado", "vendido", "alugado", "inativo"]);
export const leadSourceEnum = pgEnum("lead_source", ["site", "whatsapp", "instagram", "facebook", "indicacao", "portal_zap", "portal_vivareal", "portal_olx", "google", "outro"]);
export const leadStageEnum = pgEnum("lead_stage", ["novo", "contato_inicial", "qualificado", "visita_agendada", "visita_realizada", "proposta", "negociacao", "fechado_ganho", "fechado_perdido", "sem_interesse"]);
export const clientTypeEnum = pgEnum("client_type", ["comprador", "locatario", "proprietario"]);
export const qualificationEnum = pgEnum("qualification", ["quente", "morno", "frio", "nao_qualificado"]);
export const buyerProfileEnum = pgEnum("buyer_profile", ["investidor", "primeira_casa", "upgrade", "curioso", "indeciso"]);
export const urgencyLevelEnum = pgEnum("urgency_level", ["baixa", "media", "alta", "urgente"]);
export const priorityEnum = pgEnum("priority", ["baixa", "media", "alta", "urgente"]);
export const interactionTypeEnum = pgEnum("interaction_type", ["ligacao", "whatsapp", "email", "visita", "reuniao", "proposta", "nota", "status_change"]);
export const messageTypeEnum = pgEnum("message_type", ["incoming", "outgoing"]);
export const aiRoleEnum = pgEnum("ai_role", ["user", "assistant", "system"]);
export const interestTypeEnum = pgEnum("interest_type", ["venda", "locacao", "ambos"]);
export const webhookStatusEnum = pgEnum("webhook_status", ["success", "error", "pending"]);

// ============================================
// TABELA DE USUÁRIOS (AUTH)
// ============================================

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  openId: varchar("open_id", { length: 64 }).notNull().unique(),
  name: text("name"),
  email: varchar("email", { length: 320 }),
  loginMethod: varchar("login_method", { length: 64 }),
  role: roleEnum("role").default("user").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
  lastSignedIn: timestamp("last_signed_in").defaultNow().notNull(),
});

export type User = typeof users.$inferSelect;
export type InsertUser = typeof users.$inferInsert;

// ============================================
// TABELA DE IMÓVEIS
// ============================================

export const properties = pgTable("properties", {
  id: serial("id").primaryKey(),
  
  // Informações básicas
  title: varchar("title", { length: 255 }).notNull(),
  description: text("description"),
  referenceCode: varchar("reference_code", { length: 50 }).unique(),
  
  // Tipo e finalidade
  propertyType: propertyTypeEnum("property_type").notNull(),
  transactionType: transactionTypeEnum("transaction_type").notNull(),
  
  // Localização
  address: varchar("address", { length: 255 }),
  neighborhood: varchar("neighborhood", { length: 100 }),
  city: varchar("city", { length: 100 }),
  state: varchar("state", { length: 2 }),
  zipCode: varchar("zip_code", { length: 10 }),
  latitude: varchar("latitude", { length: 50 }),
  longitude: varchar("longitude", { length: 50 }),
  
  // Valores (em centavos)
  salePrice: integer("sale_price"),
  rentPrice: integer("rent_price"),
  condoFee: integer("condo_fee"),
  iptu: integer("iptu"),
  
  // Características
  bedrooms: integer("bedrooms"),
  bathrooms: integer("bathrooms"),
  suites: integer("suites"),
  parkingSpaces: integer("parking_spaces"),
  totalArea: integer("total_area"),
  builtArea: integer("built_area"),
  
  // Características adicionais (JSONB)
  features: jsonb("features"), // array: ["piscina", "churrasqueira", "academia"]
  
  // Imagens (JSONB array de URLs)
  images: jsonb("images"), // array de objetos: [{url: "", caption: ""}]
  mainImage: varchar("main_image", { length: 500 }),
  
  // Status e visibilidade
  status: propertyStatusEnum("status").default("disponivel").notNull(),
  featured: boolean("featured").default(false),
  published: boolean("published").default(true),
  
  // SEO
  metaTitle: varchar("meta_title", { length: 255 }),
  metaDescription: text("meta_description"),
  slug: varchar("slug", { length: 255 }).unique(),
  
  // Timestamps
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
  createdBy: integer("created_by"),
});

export type Property = typeof properties.$inferSelect;
export type InsertProperty = typeof properties.$inferInsert;

// ============================================
// TABELA DE IMAGENS DE IMÓVEIS
// ============================================

export const propertyImages = pgTable("property_images", {
  id: serial("id").primaryKey(),
  propertyId: integer("property_id").notNull(),
  imageUrl: varchar("image_url", { length: 500 }).notNull(),
  imageKey: varchar("image_key", { length: 500 }).notNull(),
  isPrimary: integer("is_primary").default(0).notNull(), // 1 = imagem principal, 0 = secundária
  displayOrder: integer("display_order").default(0).notNull(),
  caption: varchar("caption", { length: 255 }),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export type PropertyImage = typeof propertyImages.$inferSelect;
export type InsertPropertyImage = typeof propertyImages.$inferInsert;

// ============================================
// TABELA DE LEADS/CLIENTES
// ============================================

export const leads = pgTable("leads", {
  id: serial("id").primaryKey(),
  
  // Informações pessoais
  name: varchar("name", { length: 255 }).notNull(),
  email: varchar("email", { length: 320 }),
  phone: varchar("phone", { length: 20 }),
  whatsapp: varchar("whatsapp", { length: 20 }),
  
  // Origem do lead
  source: leadSourceEnum("source").default("site"),
  
  // Status no pipeline
  stage: leadStageEnum("stage").default("novo").notNull(),
  
  // Perfil do cliente
  clientType: clientTypeEnum("client_type").default("comprador").notNull(),
  qualification: qualificationEnum("qualification").default("nao_qualificado").notNull(),
  buyerProfile: buyerProfileEnum("buyer_profile"),
  urgencyLevel: urgencyLevelEnum("urgency_level").default("media"),
  
  // Interesse
  interestedPropertyId: integer("interested_property_id"),
  transactionInterest: transactionTypeEnum("transaction_interest").default("venda"),
  budgetMin: integer("budget_min"),
  budgetMax: integer("budget_max"),
  preferredNeighborhoods: jsonb("preferred_neighborhoods"),
  preferredPropertyTypes: jsonb("preferred_property_types"),
  
  // Notas e tags
  notes: text("notes"),
  tags: jsonb("tags"), // array: ["vip", "urgente", "investidor"]
  
  // Atribuição
  assignedTo: integer("assigned_to"),
  
  // Score e prioridade
  score: integer("score").default(0),
  priority: priorityEnum("priority").default("media"),
  
  // Timestamps
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
  lastContactedAt: timestamp("last_contacted_at"),
  convertedAt: timestamp("converted_at"),
});

export type Lead = typeof leads.$inferSelect;
export type InsertLead = typeof leads.$inferInsert;

// ============================================
// TABELA DE INTERAÇÕES/HISTÓRICO
// ============================================

export const interactions = pgTable("interactions", {
  id: serial("id").primaryKey(),
  
  leadId: integer("lead_id").notNull(),
  userId: integer("user_id"),
  
  type: interactionTypeEnum("type").notNull(),
  
  subject: varchar("subject", { length: 255 }),
  description: text("description"),
  
  // Metadados específicos (JSONB)
  metadata: jsonb("metadata"),
  
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export type Interaction = typeof interactions.$inferSelect;
export type InsertInteraction = typeof interactions.$inferInsert;

// ============================================
// TABELA DE BLOG POSTS
// ============================================

export const blogPosts = pgTable("blog_posts", {
  id: serial("id").primaryKey(),
  
  title: varchar("title", { length: 255 }).notNull(),
  slug: varchar("slug", { length: 255 }).unique().notNull(),
  excerpt: text("excerpt"),
  content: text("content").notNull(),
  
  featuredImage: varchar("featured_image", { length: 500 }),
  
  categoryId: integer("category_id"),
  authorId: integer("author_id"),
  
  // SEO
  metaTitle: varchar("meta_title", { length: 255 }),
  metaDescription: text("meta_description"),
  
  // Status
  published: boolean("published").default(false),
  publishedAt: timestamp("published_at"),
  
  // Estatísticas
  views: integer("views").default(0),
  
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export type BlogPost = typeof blogPosts.$inferSelect;
export type InsertBlogPost = typeof blogPosts.$inferInsert;

// ============================================
// TABELA DE CATEGORIAS DE BLOG
// ============================================

export const blogCategories = pgTable("blog_categories", {
  id: serial("id").primaryKey(),
  
  name: varchar("name", { length: 100 }).notNull(),
  slug: varchar("slug", { length: 100 }).unique().notNull(),
  description: text("description"),
  
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export type BlogCategory = typeof blogCategories.$inferSelect;
export type InsertBlogCategory = typeof blogCategories.$inferInsert;

// ============================================
// TABELA DE CONFIGURAÇÕES DO SITE
// ============================================

export const siteSettings = pgTable("site_settings", {
  id: serial("id").primaryKey(),
  
  // Informações da empresa
  companyName: varchar("company_name", { length: 255 }),
  companyDescription: text("company_description"),
  companyLogo: varchar("company_logo", { length: 500 }),
  
  // Informações do corretor
  realtorName: varchar("realtor_name", { length: 255 }),
  realtorBio: text("realtor_bio"),
  realtorCreci: varchar("realtor_creci", { length: 50 }),
  
  // Contatos
  phone: varchar("phone", { length: 20 }),
  whatsapp: varchar("whatsapp", { length: 20 }),
  email: varchar("email", { length: 320 }),
  address: text("address"),
  
  // Redes sociais
  instagram: varchar("instagram", { length: 255 }),
  facebook: varchar("facebook", { length: 255 }),
  youtube: varchar("youtube", { length: 255 }),
  tiktok: varchar("tiktok", { length: 255 }),
  linkedin: varchar("linkedin", { length: 255 }),
  
  // SEO
  siteTitle: varchar("site_title", { length: 255 }),
  siteDescription: text("site_description"),
  siteKeywords: text("site_keywords"),
  
  // Integrações
  googleAnalyticsId: varchar("google_analytics_id", { length: 50 }),
  facebookPixelId: varchar("facebook_pixel_id", { length: 50 }),
  
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export type SiteSetting = typeof siteSettings.$inferSelect;
export type InsertSiteSetting = typeof siteSettings.$inferInsert;

// ============================================
// TABELAS DE INTEGRAÇÃO WHATSAPP / N8N
// ============================================

export const messageBuffer = pgTable("message_buffer", {
  id: serial("id").primaryKey(),
  phone: varchar("phone", { length: 20 }).notNull(),
  messageId: varchar("message_id", { length: 255 }).notNull().unique(),
  content: text("content"),
  type: messageTypeEnum("type").notNull(),
  timestamp: timestamp("timestamp").defaultNow().notNull(),
  processed: integer("processed").default(0).notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export type MessageBuffer = typeof messageBuffer.$inferSelect;
export type InsertMessageBuffer = typeof messageBuffer.$inferInsert;

export const aiContextStatus = pgTable("ai_context_status", {
  id: serial("id").primaryKey(),
  sessionId: varchar("session_id", { length: 255 }).notNull(),
  phone: varchar("phone", { length: 20 }).notNull(),
  message: text("message").notNull(),
  role: aiRoleEnum("role").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export type AiContextStatus = typeof aiContextStatus.$inferSelect;
export type InsertAiContextStatus = typeof aiContextStatus.$inferInsert;

export const clientInterests = pgTable("client_interests", {
  id: serial("id").primaryKey(),
  clientId: integer("client_id").notNull(),
  propertyType: varchar("property_type", { length: 100 }),
  interestType: interestTypeEnum("interest_type"),
  budgetMin: integer("budget_min"),
  budgetMax: integer("budget_max"),
  preferredNeighborhoods: jsonb("preferred_neighborhoods"),
  notes: text("notes"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export type ClientInterest = typeof clientInterests.$inferSelect;
export type InsertClientInterest = typeof clientInterests.$inferInsert;

export const webhookLogs = pgTable("webhook_logs", {
  id: serial("id").primaryKey(),
  source: varchar("source", { length: 50 }).notNull(),
  event: varchar("event", { length: 100 }).notNull(),
  payload: jsonb("payload"),
  response: jsonb("response"),
  status: webhookStatusEnum("status").notNull(),
  errorMessage: text("error_message"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export type WebhookLog = typeof webhookLogs.$inferSelect;
export type InsertWebhookLog = typeof webhookLogs.$inferInsert;

// ============================================
// TABELA DE PROPRIETÁRIOS
// ============================================

export const owners = pgTable("owners", {
  id: serial("id").primaryKey(),
  
  // Informações pessoais
  name: varchar("name", { length: 255 }).notNull(),
  cpfCnpj: varchar("cpf_cnpj", { length: 20 }),
  email: varchar("email", { length: 320 }),
  phone: varchar("phone", { length: 20 }),
  whatsapp: varchar("whatsapp", { length: 20 }),
  
  // Endereço
  address: text("address"),
  city: varchar("city", { length: 100 }),
  state: varchar("state", { length: 2 }),
  zipCode: varchar("zip_code", { length: 10 }),
  
  // Informações bancárias
  bankName: varchar("bank_name", { length: 100 }),
  bankAgency: varchar("bank_agency", { length: 20 }),
  bankAccount: varchar("bank_account", { length: 30 }),
  pixKey: varchar("pix_key", { length: 255 }),
  
  // Notas
  notes: text("notes"),
  
  // Status
  active: boolean("active").default(true),
  
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export type Owner = typeof owners.$inferSelect;
export type InsertOwner = typeof owners.$inferInsert;

// ============================================
// TABELAS DE ANALYTICS E MÉTRICAS
// ============================================

export const analyticsEvents = pgTable("analytics_events", {
  id: serial("id").primaryKey(),
  
  eventType: varchar("event_type", { length: 50 }).notNull(),
  
  propertyId: integer("property_id"),
  leadId: integer("lead_id"),
  userId: integer("user_id"),
  
  source: varchar("source", { length: 100 }),
  medium: varchar("medium", { length: 100 }),
  campaign: varchar("campaign", { length: 255 }),
  
  url: varchar("url", { length: 500 }),
  referrer: varchar("referrer", { length: 500 }),
  userAgent: text("user_agent"),
  ipAddress: varchar("ip_address", { length: 45 }),
  
  metadata: jsonb("metadata"),
  
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export type AnalyticsEvent = typeof analyticsEvents.$inferSelect;
export type InsertAnalyticsEvent = typeof analyticsEvents.$inferInsert;

export const campaignSources = pgTable("campaign_sources", {
  id: serial("id").primaryKey(),
  
  name: varchar("name", { length: 255 }).notNull(),
  source: varchar("source", { length: 100 }).notNull(),
  medium: varchar("medium", { length: 100 }),
  campaignId: varchar("campaign_id", { length: 255 }),
  
  budget: decimal("budget", { precision: 10, scale: 2 }),
  clicks: integer("clicks").default(0),
  impressions: integer("impressions").default(0),
  conversions: integer("conversions").default(0),
  
  active: boolean("active").default(true),
  startDate: date("start_date"),
  endDate: date("end_date"),
  
  notes: text("notes"),
  
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export type CampaignSource = typeof campaignSources.$inferSelect;
export type InsertCampaignSource = typeof campaignSources.$inferInsert;

// ============================================
// TABELAS FINANCEIRAS
// ============================================

export const transactions = pgTable("transactions", {
  id: serial("id").primaryKey(),
  
  type: varchar("type", { length: 50 }).notNull(),
  category: varchar("category", { length: 100 }),
  
  amount: decimal("amount", { precision: 12, scale: 2 }).notNull(),
  currency: varchar("currency", { length: 3 }).default("BRL"),
  
  propertyId: integer("property_id"),
  leadId: integer("lead_id"),
  ownerId: integer("owner_id"),
  
  description: text("description").notNull(),
  notes: text("notes"),
  
  status: varchar("status", { length: 50 }).default("pending"),
  paymentMethod: varchar("payment_method", { length: 50 }),
  paymentDate: date("payment_date"),
  dueDate: date("due_date"),
  
  receiptUrl: varchar("receipt_url", { length: 500 }),
  invoiceNumber: varchar("invoice_number", { length: 100 }),
  
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export type Transaction = typeof transactions.$inferSelect;
export type InsertTransaction = typeof transactions.$inferInsert;

export const commissions = pgTable("commissions", {
  id: serial("id").primaryKey(),
  
  propertyId: integer("property_id").notNull(),
  leadId: integer("lead_id").notNull(),
  ownerId: integer("owner_id"),
  
  salePrice: decimal("sale_price", { precision: 12, scale: 2 }).notNull(),
  commissionRate: decimal("commission_rate", { precision: 5, scale: 2 }).notNull(),
  commissionAmount: decimal("commission_amount", { precision: 12, scale: 2 }).notNull(),
  
  splitWithAgent: boolean("split_with_agent").default(false),
  agentName: varchar("agent_name", { length: 255 }),
  agentCommissionAmount: decimal("agent_commission_amount", { precision: 12, scale: 2 }),
  
  status: varchar("status", { length: 50 }).default("pending"),
  paymentDate: date("payment_date"),
  
  notes: text("notes"),
  
  transactionId: integer("transaction_id"),
  
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export type Commission = typeof commissions.$inferSelect;
export type InsertCommission = typeof commissions.$inferInsert;

// ============================================
// TABELA DE AVALIAÇÕES DE CLIENTES
// ============================================

export const reviews = pgTable("reviews", {
  id: serial("id").primaryKey(),
  
  clientName: varchar("client_name", { length: 255 }).notNull(),
  clientRole: varchar("client_role", { length: 100 }),
  clientPhoto: varchar("client_photo", { length: 500 }),
  
  rating: integer("rating").notNull(),
  title: varchar("title", { length: 255 }),
  content: text("content").notNull(),
  
  propertyId: integer("property_id"),
  leadId: integer("lead_id"),
  
  approved: boolean("approved").default(false),
  featured: boolean("featured").default(false),
  
  displayOrder: integer("display_order").default(0),
  
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export type Review = typeof reviews.$inferSelect;
export type InsertReview = typeof reviews.$inferInsert;
