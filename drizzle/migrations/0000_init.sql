-- Migration: 0000_init
-- Created: 2025-12-02
-- Description: Schema completo do CasaDF para PostgreSQL

-- ============================================
-- ENUMS
-- ============================================

DO $$ BEGIN
 CREATE TYPE "role" AS ENUM('user', 'admin');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "property_type" AS ENUM('casa', 'apartamento', 'cobertura', 'terreno', 'comercial', 'rural', 'lancamento');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "transaction_type" AS ENUM('venda', 'locacao', 'ambos');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "property_status" AS ENUM('disponivel', 'reservado', 'vendido', 'alugado', 'inativo');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "lead_source" AS ENUM('site', 'whatsapp', 'instagram', 'facebook', 'indicacao', 'portal_zap', 'portal_vivareal', 'portal_olx', 'google', 'outro');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "lead_stage" AS ENUM('novo', 'contato_inicial', 'qualificado', 'visita_agendada', 'visita_realizada', 'proposta', 'negociacao', 'fechado_ganho', 'fechado_perdido', 'sem_interesse');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "client_type" AS ENUM('comprador', 'locatario', 'proprietario');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "qualification" AS ENUM('quente', 'morno', 'frio', 'nao_qualificado');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "buyer_profile" AS ENUM('investidor', 'primeira_casa', 'upgrade', 'curioso', 'indeciso');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "urgency_level" AS ENUM('baixa', 'media', 'alta', 'urgente');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "priority" AS ENUM('baixa', 'media', 'alta', 'urgente');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "interaction_type" AS ENUM('ligacao', 'whatsapp', 'email', 'visita', 'reuniao', 'proposta', 'nota', 'status_change');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "message_type" AS ENUM('incoming', 'outgoing');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "ai_role" AS ENUM('user', 'assistant', 'system');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "interest_type" AS ENUM('venda', 'locacao', 'ambos');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "webhook_status" AS ENUM('success', 'error', 'pending');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

-- ============================================
-- TABELAS
-- ============================================

-- Usuários
CREATE TABLE IF NOT EXISTS "users" (
	"id" serial PRIMARY KEY NOT NULL,
	"open_id" varchar(64) NOT NULL UNIQUE,
	"name" text,
	"email" varchar(320),
	"avatar_url" text,
	"role" "role" DEFAULT 'user' NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);

-- Imóveis
CREATE TABLE IF NOT EXISTS "properties" (
	"id" serial PRIMARY KEY NOT NULL,
	"title" varchar(255) NOT NULL,
	"description" text,
	"reference_code" varchar(50),
	"property_type" "property_type" NOT NULL,
	"transaction_type" "transaction_type" NOT NULL,
	"address" text,
	"neighborhood" varchar(100),
	"city" varchar(100) DEFAULT 'Brasília',
	"state" varchar(2) DEFAULT 'DF',
	"zip_code" varchar(10),
	"latitude" varchar(50),
	"longitude" varchar(50),
	"sale_price" decimal(12,2),
	"rent_price" decimal(12,2),
	"condo_fee" decimal(10,2),
	"iptu" decimal(10,2),
	"bedrooms" integer,
	"bathrooms" integer,
	"suites" integer,
	"parking_spaces" integer,
	"total_area" decimal(10,2),
	"built_area" decimal(10,2),
	"features" text,
	"images" text,
	"main_image" text,
	"status" "property_status" DEFAULT 'disponivel' NOT NULL,
	"featured" boolean DEFAULT false,
	"published" boolean DEFAULT true,
	"views" integer DEFAULT 0,
	"meta_title" varchar(255),
	"meta_description" text,
	"slug" varchar(255),
	"owner_id" integer,
	"created_by" integer,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);

-- Imagens dos Imóveis
CREATE TABLE IF NOT EXISTS "property_images" (
	"id" serial PRIMARY KEY NOT NULL,
	"property_id" integer NOT NULL,
	"url" text NOT NULL,
	"is_main" boolean DEFAULT false,
	"order" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now() NOT NULL
);

-- Leads/Clientes
CREATE TABLE IF NOT EXISTS "leads" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(255) NOT NULL,
	"email" varchar(320),
	"phone" varchar(20),
	"whatsapp" varchar(20),
	"client_type" "client_type" DEFAULT 'comprador',
	"lead_source" "lead_source" DEFAULT 'site',
	"lead_stage" "lead_stage" DEFAULT 'novo' NOT NULL,
	"qualification" "qualification" DEFAULT 'nao_qualificado',
	"buyer_profile" "buyer_profile",
	"urgency_level" "urgency_level" DEFAULT 'media',
	"budget_min" decimal(12,2),
	"budget_max" decimal(12,2),
	"preferred_neighborhoods" text,
	"property_interest" text,
	"notes" text,
	"tags" text,
	"assigned_to" integer,
	"last_interaction_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);

-- Interações
CREATE TABLE IF NOT EXISTS "interactions" (
	"id" serial PRIMARY KEY NOT NULL,
	"lead_id" integer NOT NULL,
	"interaction_type" "interaction_type" NOT NULL,
	"subject" varchar(255),
	"description" text,
	"outcome" text,
	"next_action" text,
	"next_action_date" timestamp,
	"priority" "priority" DEFAULT 'media',
	"created_by" integer,
	"created_at" timestamp DEFAULT now() NOT NULL
);

-- Posts do Blog
CREATE TABLE IF NOT EXISTS "blog_posts" (
	"id" serial PRIMARY KEY NOT NULL,
	"title" varchar(255) NOT NULL,
	"slug" varchar(255) NOT NULL UNIQUE,
	"excerpt" text,
	"content" text NOT NULL,
	"cover_image" text,
	"category_id" integer,
	"author_id" integer,
	"published" boolean DEFAULT false,
	"views" integer DEFAULT 0,
	"meta_title" varchar(255),
	"meta_description" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	"published_at" timestamp
);

-- Categorias do Blog
CREATE TABLE IF NOT EXISTS "blog_categories" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(100) NOT NULL,
	"slug" varchar(100) NOT NULL UNIQUE,
	"description" text,
	"created_at" timestamp DEFAULT now() NOT NULL
);

-- Configurações do Site
CREATE TABLE IF NOT EXISTS "site_settings" (
	"id" serial PRIMARY KEY NOT NULL,
	"key" varchar(100) NOT NULL UNIQUE,
	"value" text,
	"updated_at" timestamp DEFAULT now() NOT NULL
);

-- Buffer de Mensagens WhatsApp
CREATE TABLE IF NOT EXISTS "message_buffer" (
	"id" serial PRIMARY KEY NOT NULL,
	"lead_id" integer,
	"phone_number" varchar(20) NOT NULL,
	"message_type" "message_type" NOT NULL,
	"content" text NOT NULL,
	"timestamp" timestamp DEFAULT now() NOT NULL,
	"webhook_data" jsonb,
	"created_at" timestamp DEFAULT now() NOT NULL
);

-- Status do Contexto de IA
CREATE TABLE IF NOT EXISTS "ai_context_status" (
	"id" serial PRIMARY KEY NOT NULL,
	"lead_id" integer NOT NULL UNIQUE,
	"phone_number" varchar(20) NOT NULL,
	"context_summary" text,
	"last_message_role" "ai_role",
	"conversation_stage" varchar(50),
	"needs_qualification" boolean DEFAULT true,
	"updated_at" timestamp DEFAULT now() NOT NULL
);

-- Interesses dos Clientes
CREATE TABLE IF NOT EXISTS "client_interests" (
	"id" serial PRIMARY KEY NOT NULL,
	"lead_id" integer NOT NULL,
	"property_id" integer,
	"interest_type" "interest_type" NOT NULL,
	"min_price" decimal(12,2),
	"max_price" decimal(12,2),
	"preferred_neighborhoods" text,
	"min_bedrooms" integer,
	"property_types" text,
	"notes" text,
	"created_at" timestamp DEFAULT now() NOT NULL
);

-- Logs de Webhooks
CREATE TABLE IF NOT EXISTS "webhook_logs" (
	"id" serial PRIMARY KEY NOT NULL,
	"endpoint" varchar(100) NOT NULL,
	"method" varchar(10) NOT NULL,
	"payload" jsonb,
	"response" jsonb,
	"status" "webhook_status" NOT NULL,
	"error_message" text,
	"created_at" timestamp DEFAULT now() NOT NULL
);

-- Proprietários
CREATE TABLE IF NOT EXISTS "owners" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(255) NOT NULL,
	"email" varchar(320),
	"phone" varchar(20),
	"cpf_cnpj" varchar(20),
	"address" text,
	"notes" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);

-- Eventos de Analytics
CREATE TABLE IF NOT EXISTS "analytics_events" (
	"id" serial PRIMARY KEY NOT NULL,
	"event_type" varchar(50) NOT NULL,
	"property_id" integer,
	"lead_id" integer,
	"campaign_source" varchar(100),
	"metadata" jsonb,
	"created_at" timestamp DEFAULT now() NOT NULL
);

-- Fontes de Campanhas
CREATE TABLE IF NOT EXISTS "campaign_sources" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(100) NOT NULL,
	"utm_source" varchar(100),
	"utm_medium" varchar(100),
	"utm_campaign" varchar(100),
	"budget" decimal(10,2),
	"leads_count" integer DEFAULT 0,
	"conversions_count" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now() NOT NULL
);

-- Avaliações
CREATE TABLE IF NOT EXISTS "reviews" (
	"id" serial PRIMARY KEY NOT NULL,
	"lead_id" integer,
	"property_id" integer,
	"rating" integer NOT NULL,
	"comment" text,
	"approved" boolean DEFAULT false,
	"created_at" timestamp DEFAULT now() NOT NULL
);

-- Transações Financeiras
CREATE TABLE IF NOT EXISTS "transactions" (
	"id" serial PRIMARY KEY NOT NULL,
	"property_id" integer NOT NULL,
	"lead_id" integer NOT NULL,
	"transaction_type" "transaction_type" NOT NULL,
	"amount" decimal(12,2) NOT NULL,
	"commission_percentage" decimal(5,2),
	"commission_amount" decimal(12,2),
	"status" varchar(50) DEFAULT 'pending',
	"contract_date" date,
	"closing_date" date,
	"notes" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);

-- Comissões
CREATE TABLE IF NOT EXISTS "commissions" (
	"id" serial PRIMARY KEY NOT NULL,
	"transaction_id" integer NOT NULL,
	"user_id" integer NOT NULL,
	"amount" decimal(12,2) NOT NULL,
	"percentage" decimal(5,2),
	"paid" boolean DEFAULT false,
	"paid_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL
);

-- ============================================
-- FOREIGN KEYS
-- ============================================

ALTER TABLE "property_images" ADD CONSTRAINT "property_images_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE;
ALTER TABLE "interactions" ADD CONSTRAINT "interactions_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE CASCADE;
ALTER TABLE "blog_posts" ADD CONSTRAINT "blog_posts_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "blog_categories"("id") ON DELETE SET NULL;
ALTER TABLE "message_buffer" ADD CONSTRAINT "message_buffer_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE SET NULL;
ALTER TABLE "ai_context_status" ADD CONSTRAINT "ai_context_status_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE CASCADE;
ALTER TABLE "client_interests" ADD CONSTRAINT "client_interests_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE CASCADE;
ALTER TABLE "client_interests" ADD CONSTRAINT "client_interests_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL;
ALTER TABLE "properties" ADD CONSTRAINT "properties_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "owners"("id") ON DELETE SET NULL;
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE;
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE CASCADE;
ALTER TABLE "commissions" ADD CONSTRAINT "commissions_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "transactions"("id") ON DELETE CASCADE;
ALTER TABLE "commissions" ADD CONSTRAINT "commissions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE;

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS "properties_status_idx" ON "properties"("status");
CREATE INDEX IF NOT EXISTS "properties_featured_idx" ON "properties"("featured");
CREATE INDEX IF NOT EXISTS "properties_neighborhood_idx" ON "properties"("neighborhood");
CREATE INDEX IF NOT EXISTS "leads_stage_idx" ON "leads"("lead_stage");
CREATE INDEX IF NOT EXISTS "leads_qualification_idx" ON "leads"("qualification");
CREATE INDEX IF NOT EXISTS "leads_phone_idx" ON "leads"("phone");
CREATE INDEX IF NOT EXISTS "blog_posts_slug_idx" ON "blog_posts"("slug");
CREATE INDEX IF NOT EXISTS "message_buffer_phone_idx" ON "message_buffer"("phone_number");
CREATE INDEX IF NOT EXISTS "analytics_events_type_idx" ON "analytics_events"("event_type");

-- ============================================
-- DADOS INICIAIS
-- ============================================

-- Categoria padrão do blog
INSERT INTO "blog_categories" ("name", "slug", "description")
VALUES ('Geral', 'geral', 'Categoria geral para posts do blog')
ON CONFLICT ("slug") DO NOTHING;

-- Configurações iniciais
INSERT INTO "site_settings" ("key", "value")
VALUES 
  ('site_name', 'CasaDF'),
  ('site_description', 'Imóveis em Brasília'),
  ('contact_email', 'contato@casadf.com.br'),
  ('contact_phone', '(61) 3254-4464'),
  ('contact_whatsapp', '(61) 98129-9575')
ON CONFLICT ("key") DO NOTHING;
