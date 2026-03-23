CREATE TYPE "public"."backtest_status" AS ENUM('pending', 'running', 'completed', 'failed');--> statement-breakpoint
CREATE TYPE "public"."cache_status" AS ENUM('empty', 'partial', 'complete');--> statement-breakpoint
CREATE TYPE "public"."role" AS ENUM('user', 'admin');--> statement-breakpoint
CREATE TYPE "public"."side" AS ENUM('buy', 'sell');--> statement-breakpoint
CREATE TYPE "public"."strategy" AS ENUM('standard', 'aggressive', 'ladder_cd_combo', 'mean_reversion', 'macd_volume', 'bollinger_squeeze', 'gemini_ai');--> statement-breakpoint
CREATE TYPE "public"."warming_status" AS ENUM('pending', 'success', 'failed');--> statement-breakpoint
CREATE TABLE "ai_configs" (
	"id" serial PRIMARY KEY NOT NULL,
	"userId" integer NOT NULL,
	"provider" varchar(50) NOT NULL,
	"apiEndpoint" varchar(500) NOT NULL,
	"apiKey" varchar(500) NOT NULL,
	"model" varchar(100) NOT NULL,
	"isActive" boolean DEFAULT true,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "backtest_sessions" (
	"id" serial PRIMARY KEY NOT NULL,
	"userId" integer NOT NULL,
	"name" varchar(255) NOT NULL,
	"strategy" "strategy" NOT NULL,
	"strategyParams" json,
	"status" "backtest_status" DEFAULT 'pending' NOT NULL,
	"symbols" json NOT NULL,
	"startDate" varchar(10) NOT NULL,
	"endDate" varchar(10) NOT NULL,
	"initialCapital" numeric(15, 2) DEFAULT '100000' NOT NULL,
	"maxPositionPct" numeric(5, 2) DEFAULT '10' NOT NULL,
	"totalReturn" numeric(15, 4),
	"totalReturnPct" numeric(10, 4),
	"winRate" numeric(5, 4),
	"maxDrawdown" numeric(10, 4),
	"sharpeRatio" numeric(10, 4),
	"totalTrades" integer,
	"winningTrades" integer,
	"losingTrades" integer,
	"benchmarkReturn" numeric(10, 4),
	"totalCommissionFee" numeric(15, 2) DEFAULT '0',
	"totalPlatformFee" numeric(15, 2) DEFAULT '0',
	"progress" integer DEFAULT 0,
	"progressMessage" text,
	"resultSummary" json,
	"aiAnalysis" text,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"completedAt" timestamp
);
--> statement-breakpoint
CREATE TABLE "backtest_trades" (
	"id" serial PRIMARY KEY NOT NULL,
	"sessionId" integer NOT NULL,
	"symbol" varchar(20) NOT NULL,
	"side" "side" NOT NULL,
	"quantity" numeric(15, 4) NOT NULL,
	"price" numeric(15, 4) NOT NULL,
	"totalAmount" numeric(15, 2) NOT NULL,
	"fee" numeric(10, 4) DEFAULT '0',
	"commissionFee" numeric(15, 2) DEFAULT '0',
	"platformFee" numeric(15, 2) DEFAULT '0',
	"reason" text,
	"signalType" varchar(50),
	"tradeTime" bigint NOT NULL,
	"pnl" numeric(15, 2),
	"pnlPct" numeric(10, 4),
	"createdAt" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "cache_metadata" (
	"id" serial PRIMARY KEY NOT NULL,
	"symbol" varchar(20) NOT NULL,
	"timeframe" varchar(10) NOT NULL,
	"oldestDate" varchar(30),
	"newestDate" varchar(30),
	"candleCount" integer DEFAULT 0,
	"lastUpdated" timestamp DEFAULT now(),
	"status" "cache_status" DEFAULT 'empty'
);
--> statement-breakpoint
CREATE TABLE "custom_data_sources" (
	"id" serial PRIMARY KEY NOT NULL,
	"userId" integer NOT NULL,
	"name" varchar(100) NOT NULL,
	"provider" varchar(50) NOT NULL,
	"apiEndpoint" varchar(500),
	"apiKey" varchar(500),
	"description" text,
	"isActive" boolean DEFAULT true,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "data_source_health" (
	"id" serial PRIMARY KEY NOT NULL,
	"source" varchar(30) NOT NULL,
	"timeframe" varchar(10) NOT NULL,
	"successCount" integer DEFAULT 0,
	"failCount" integer DEFAULT 0,
	"lastSuccess" timestamp,
	"lastFail" timestamp,
	"lastError" text,
	"updatedAt" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "historical_candle_cache" (
	"id" serial PRIMARY KEY NOT NULL,
	"symbol" varchar(20) NOT NULL,
	"timeframe" varchar(10) NOT NULL,
	"date" varchar(30) NOT NULL,
	"open" numeric(15, 4) NOT NULL,
	"high" numeric(15, 4) NOT NULL,
	"low" numeric(15, 4) NOT NULL,
	"close" numeric(15, 4) NOT NULL,
	"volume" bigint DEFAULT 0
);
--> statement-breakpoint
CREATE TABLE "scheduled_warming_tasks" (
	"id" serial PRIMARY KEY NOT NULL,
	"userId" integer NOT NULL,
	"name" varchar(255) NOT NULL,
	"description" text,
	"sectors" json,
	"marketCapTiers" json,
	"customSymbols" json,
	"cronExpression" varchar(100) NOT NULL,
	"isEnabled" boolean DEFAULT true,
	"lastExecutedAt" timestamp,
	"nextExecutedAt" timestamp,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" serial PRIMARY KEY NOT NULL,
	"openId" varchar(64) NOT NULL,
	"username" varchar(64),
	"passwordHash" varchar(255),
	"name" text,
	"email" varchar(320),
	"loginMethod" varchar(64),
	"role" "role" DEFAULT 'user' NOT NULL,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"updatedAt" timestamp DEFAULT now() NOT NULL,
	"lastSignedIn" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "users_openId_unique" UNIQUE("openId"),
	CONSTRAINT "users_username_unique" UNIQUE("username")
);
--> statement-breakpoint
CREATE TABLE "warming_progress" (
	"id" serial PRIMARY KEY NOT NULL,
	"userId" integer NOT NULL,
	"taskId" varchar(64) NOT NULL,
	"symbol" varchar(20) NOT NULL,
	"status" "warming_status" DEFAULT 'pending' NOT NULL,
	"dataSource" varchar(30),
	"errorMessage" text,
	"duration" integer,
	"createdAt" timestamp DEFAULT now() NOT NULL,
	"completedAt" timestamp,
	CONSTRAINT "warming_progress_taskId_unique" UNIQUE("taskId")
);
--> statement-breakpoint
CREATE TABLE "warming_stats" (
	"id" serial PRIMARY KEY NOT NULL,
	"userId" integer NOT NULL,
	"dataSource" varchar(30) NOT NULL,
	"successCount" integer DEFAULT 0,
	"failCount" integer DEFAULT 0,
	"totalDuration" bigint DEFAULT 0,
	"averageDuration" numeric(10, 2) DEFAULT '0',
	"lastUpdated" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE UNIQUE INDEX "idx_ai_user_provider" ON "ai_configs" USING btree ("userId","provider");--> statement-breakpoint
CREATE INDEX "idx_ai_user_active" ON "ai_configs" USING btree ("userId","isActive");--> statement-breakpoint
CREATE INDEX "idx_session" ON "backtest_trades" USING btree ("sessionId");--> statement-breakpoint
CREATE UNIQUE INDEX "idx_cm_symbol_tf" ON "cache_metadata" USING btree ("symbol","timeframe");--> statement-breakpoint
CREATE INDEX "idx_cds_user_id" ON "custom_data_sources" USING btree ("userId");--> statement-breakpoint
CREATE INDEX "idx_cds_user_active" ON "custom_data_sources" USING btree ("userId","isActive");--> statement-breakpoint
CREATE UNIQUE INDEX "idx_dsh_source_tf" ON "data_source_health" USING btree ("source","timeframe");--> statement-breakpoint
CREATE UNIQUE INDEX "idx_symbol_tf_date" ON "historical_candle_cache" USING btree ("symbol","timeframe","date");--> statement-breakpoint
CREATE INDEX "idx_symbol_tf" ON "historical_candle_cache" USING btree ("symbol","timeframe");--> statement-breakpoint
CREATE INDEX "idx_swt_user_id" ON "scheduled_warming_tasks" USING btree ("userId");--> statement-breakpoint
CREATE INDEX "idx_swt_enabled" ON "scheduled_warming_tasks" USING btree ("isEnabled");--> statement-breakpoint
CREATE INDEX "idx_swt_next_executed" ON "scheduled_warming_tasks" USING btree ("nextExecutedAt");--> statement-breakpoint
CREATE INDEX "idx_wp_task_id" ON "warming_progress" USING btree ("taskId");--> statement-breakpoint
CREATE INDEX "idx_wp_user_id" ON "warming_progress" USING btree ("userId");--> statement-breakpoint
CREATE INDEX "idx_wp_status" ON "warming_progress" USING btree ("status");--> statement-breakpoint
CREATE UNIQUE INDEX "idx_user_source" ON "warming_stats" USING btree ("userId","dataSource");