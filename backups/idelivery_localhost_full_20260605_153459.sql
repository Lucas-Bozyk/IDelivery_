--
-- PostgreSQL database cluster dump
--

\restrict FQgf7mGy3AjkQeZ3HyCt8dvJYJjWMiyPCbjhHF0rXZbLU5fkGrIr4YzVoRjjddB

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:mI3FIi2khtZSrsbpJdalMA==$l0KsFl6mHIkg8V9df+Mir67BULlhz0DV2RP9c7PEUnI=:6BgKr8FFn2pX784+o82YsBICQ0JKelFmJ23o6oBwgGQ=';

--
-- User Configurations
--








\unrestrict FQgf7mGy3AjkQeZ3HyCt8dvJYJjWMiyPCbjhHF0rXZbLU5fkGrIr4YzVoRjjddB

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict 4LyE5goqau2uA8K8pdsgTZJvaGQ6uxt9bQIYhXPckh2Ozm6VLcYbRA0eTWIKSb8

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

\unrestrict 4LyE5goqau2uA8K8pdsgTZJvaGQ6uxt9bQIYhXPckh2Ozm6VLcYbRA0eTWIKSb8

--
-- Database "api_licence" dump
--

--
-- PostgreSQL database dump
--

\restrict 1bErzYHd0OuGErDgaB6HwaINWdnplNRk8gdIjUtf03wnhjJyCuTy2jKZjiaDFL1

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: api_licence; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE api_licence WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Portuguese_Brazil.1252';


ALTER DATABASE api_licence OWNER TO postgres;

\unrestrict 1bErzYHd0OuGErDgaB6HwaINWdnplNRk8gdIjUtf03wnhjJyCuTy2jKZjiaDFL1
\connect api_licence
\restrict 1bErzYHd0OuGErDgaB6HwaINWdnplNRk8gdIjUtf03wnhjJyCuTy2jKZjiaDFL1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- Name: brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.brands (
    "Id" uuid NOT NULL,
    "Name" character varying(100) NOT NULL,
    "Slug" character varying(150) NOT NULL,
    "LogoUrl" text,
    "Active" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone
);


ALTER TABLE public.brands OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    "Id" uuid NOT NULL,
    "Name" character varying(100) NOT NULL,
    "Slug" character varying(150) NOT NULL,
    "Active" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: licenses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.licenses (
    "Id" uuid NOT NULL,
    "Key" character varying(500) NOT NULL,
    "Status" integer NOT NULL,
    "AssignedAt" timestamp with time zone,
    "ExpiresAt" timestamp with time zone,
    "ProductId" uuid NOT NULL,
    "OrderId" uuid,
    "UserId" uuid,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone
);


ALTER TABLE public.licenses OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "ProductId" uuid NOT NULL,
    "Quantity" integer NOT NULL,
    "TotalPrice" numeric(10,2) NOT NULL,
    "Status" integer NOT NULL,
    "Notes" text,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "ActivationEmail" character varying(320),
    "DeliveryActive" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: outbox_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.outbox_messages (
    "Id" uuid NOT NULL,
    "Type" character varying(300) NOT NULL,
    "Payload" jsonb NOT NULL,
    "OccurredAt" timestamp with time zone NOT NULL,
    "ProcessedAt" timestamp with time zone,
    "Error" character varying(1000),
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone
);


ALTER TABLE public.outbox_messages OWNER TO postgres;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    "Id" uuid NOT NULL,
    "OrderId" uuid NOT NULL,
    "Platform" integer NOT NULL,
    "Status" integer NOT NULL,
    "Amount" numeric(10,2) NOT NULL,
    "Currency" character varying(3) NOT NULL,
    "ExternalPaymentId" character varying(200),
    "CheckoutUrl" character varying(1000),
    "FailureReason" character varying(500),
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: product_images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_images (
    "Id" uuid NOT NULL,
    "ProductId" uuid NOT NULL,
    "Url" character varying(1000) NOT NULL,
    "AltText" character varying(300),
    "SortOrder" integer DEFAULT 0 NOT NULL,
    "IsPrimary" boolean DEFAULT false NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone
);


ALTER TABLE public.product_images OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    "Id" uuid NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Description" text NOT NULL,
    "Price" numeric(10,2) NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "ShortDescription" text DEFAULT ''::text CONSTRAINT "products_Category_not_null" NOT NULL,
    "Active" boolean DEFAULT true NOT NULL,
    "BrandId" uuid,
    "CategoryId" uuid,
    "PromotionalPrice" numeric(10,2),
    "Slug" character varying(250) DEFAULT ''::character varying NOT NULL,
    "DeliveryType" integer DEFAULT 0 NOT NULL,
    "RequiresActivationEmail" boolean DEFAULT false NOT NULL,
    "PrimaryImageId" uuid
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    "Id" uuid NOT NULL,
    "Token" text NOT NULL,
    "ExpiresAt" timestamp with time zone NOT NULL,
    "RevokedAt" timestamp with time zone,
    "UserId" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- Name: role_claims; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_claims (
    "Id" integer NOT NULL,
    "RoleId" uuid NOT NULL,
    "ClaimType" text,
    "ClaimValue" text
);


ALTER TABLE public.role_claims OWNER TO postgres;

--
-- Name: role_claims_Id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.role_claims ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."role_claims_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    "Id" uuid NOT NULL,
    "Name" character varying(256),
    "NormalizedName" character varying(256),
    "ConcurrencyStamp" text
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: user_claims; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_claims (
    "Id" integer NOT NULL,
    "UserId" uuid NOT NULL,
    "ClaimType" text,
    "ClaimValue" text
);


ALTER TABLE public.user_claims OWNER TO postgres;

--
-- Name: user_claims_Id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.user_claims ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."user_claims_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_logins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_logins (
    "LoginProvider" text NOT NULL,
    "ProviderKey" text NOT NULL,
    "ProviderDisplayName" text,
    "UserId" uuid NOT NULL
);


ALTER TABLE public.user_logins OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    "UserId" uuid NOT NULL,
    "RoleId" uuid NOT NULL
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_tokens (
    "UserId" uuid NOT NULL,
    "LoginProvider" text NOT NULL,
    "Name" text NOT NULL,
    "Value" text
);


ALTER TABLE public.user_tokens OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    "Id" uuid NOT NULL,
    "FullName" text NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "IsActive" boolean NOT NULL,
    "UserName" character varying(256),
    "NormalizedUserName" character varying(256),
    "Email" character varying(256),
    "NormalizedEmail" character varying(256),
    "EmailConfirmed" boolean NOT NULL,
    "PasswordHash" text,
    "SecurityStamp" text,
    "ConcurrencyStamp" text,
    "PhoneNumber" text,
    "PhoneNumberConfirmed" boolean NOT NULL,
    "TwoFactorEnabled" boolean NOT NULL,
    "LockoutEnd" timestamp with time zone,
    "LockoutEnabled" boolean NOT NULL,
    "AccessFailedCount" integer NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20260513163947_InitialCreate	9.0.0
20260513180504_AddOutboxMessages	9.0.0
20260513193339_AddCategoryToProducts	9.0.0
20260514161629_AddImageToProducts	9.0.0
20260514175550_AddSeed	9.0.0
20260514214013_Brand	9.0.0
20260514222330_ProductDeliveryConfiguration	9.0.0
20260514224855_Update	9.0.0
20260515163556_RemoveSlug	9.0.0
20260515182011_Ajustes	9.0.0
20260525032619_AddProductImagesMetadata	9.0.0
\.


--
-- Data for Name: brands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.brands ("Id", "Name", "Slug", "LogoUrl", "Active", "CreatedAt", "UpdatedAt") FROM stdin;
61cbe764-3a50-4aa7-9854-155c59859ef3	Autodesk	autodesk-Inventor	\\autodesk-inventor1.png	t	2026-05-15 15:34:53.174993-03	2026-05-24 23:47:13.512074-03
58fba2af-0cd9-4b5b-bebd-d1911727b33a	Windows	windows-11-pro	\\win-11-pro.png	t	2026-05-14 18:43:54.947341-03	2026-05-24 23:48:06.097711-03
3cae9fe3-4440-4264-9b36-c0f653c10d13	Office	Office-2021	\\office-2021.png	t	2026-05-17 11:23:32.27187-03	2026-05-24 23:48:45.996731-03
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories ("Id", "Name", "Slug", "Active", "CreatedAt", "UpdatedAt") FROM stdin;
471781f7-1179-4279-8ee5-cc36dc49061b	Adobe	Adobe	t	2026-05-16 21:46:46.80822-03	\N
4f3d10bc-4ed2-468d-83a6-8aad927784c8	Windows	Microsoft-Company	t	2026-05-14 18:11:20.420125-03	2026-05-17 13:57:46.082455-03
2aad6332-43b3-46e5-ab61-e2aa7afc5d9c	Autodesk	Autodesk-Company	t	2026-05-16 21:45:38.123233-03	2026-05-17 13:57:53.180243-03
03cb1d1a-15df-4a16-a102-6b3b3fe34d1e	Pacote Office	Pacote-Office	t	2026-05-16 21:45:53.518119-03	2026-05-17 13:58:24.510537-03
30420cf7-ddfe-42d3-bf34-390ff6034a1c	Windows Server	Windows-Server	t	2026-05-16 21:46:08.97161-03	2026-05-17 13:58:34.978966-03
91142f14-c810-4bf0-95d0-02e44a299d6f	SQL Server	SQL-Server	t	2026-05-16 21:47:53.797172-03	2026-05-17 13:59:00.279328-03
3a222117-6257-4d84-be3b-1d3c6191fd8c	Corel Draw	Corel-Draw	t	2026-05-16 21:48:58.978439-03	2026-05-21 14:13:28.133847-03
\.


--
-- Data for Name: licenses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.licenses ("Id", "Key", "Status", "AssignedAt", "ExpiresAt", "ProductId", "OrderId", "UserId", "CreatedAt", "UpdatedAt") FROM stdin;
ef054b44-96ff-4d97-abf9-0cc3e1bcd977	ghghgh	1	2026-05-17 14:32:12.138359-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	4ec75f42-6fac-475c-92a1-b129b1bde9c1	019e3644-d678-723c-9007-bcc56383c267	2026-05-17 14:32:12.138033-03	\N
08169c43-77e6-458f-b3d4-95fa4ec16d88	wtretret	1	2026-05-17 14:33:01.37164-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	dc571716-745f-479f-8fee-2b8aee50c95e	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:33:01.371638-03	\N
9dce5bef-ca16-4385-bd62-bb368f3cb6b8	ertertert	1	2026-05-17 14:33:04.217007-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	dc70833f-525a-4050-a245-0b967f7cc627	019e3644-d678-723c-9007-bcc56383c267	2026-05-17 14:33:04.217005-03	\N
d91da00c-d28c-4f2d-be1f-79057a03badc	435345345	1	2026-05-17 14:33:07.48799-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	dc571716-745f-479f-8fee-2b8aee50c95e	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:33:07.487986-03	\N
b380949b-079a-45e4-894d-350d901dc24a	345435	1	2026-05-17 14:33:12.292202-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	dc571716-745f-479f-8fee-2b8aee50c95e	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:33:12.292201-03	\N
b6446dc4-4a66-42bb-a10e-28790354749e	uyiyuiyiyi	1	2026-05-17 14:39:48.892857-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	c553a342-adca-498d-8aa6-49f253adf8a3	019e3644-d678-723c-9007-bcc56383c267	2026-05-17 14:39:48.892846-03	\N
31b7f21a-80d0-41d1-92cc-4ae184309971	yuiyuiyui	1	2026-05-17 14:39:51.073365-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	6a5a91ea-1d22-4d58-93d0-67c47ec2c36d	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:39:51.073362-03	\N
f1f5c8c1-09db-474d-b744-1e283f491ec7	yuiyuiyui	1	2026-05-17 14:39:52.972819-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	6a5a91ea-1d22-4d58-93d0-67c47ec2c36d	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:39:52.972816-03	\N
3ae0c7f9-24e2-47c1-a11e-41b3d1c9dd10	yuiyiyui	1	2026-05-17 14:39:54.794113-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	6a5a91ea-1d22-4d58-93d0-67c47ec2c36d	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:39:54.794109-03	\N
f2bb36c6-edd4-4252-a9a6-13057528f898	sdfsdf	1	2026-05-17 14:46:18.576852-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	387e8e75-696d-45b9-89a6-fa95d826f07f	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:46:18.576848-03	\N
4f6d636e-a3ef-4a4a-aacd-6adb13e09fdc	sdfsdf	1	2026-05-17 14:46:20.300814-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	6a5a91ea-1d22-4d58-93d0-67c47ec2c36d	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:46:20.300811-03	\N
eb78881a-ba45-40c2-bd62-87166b341809	sdfsdf	1	2026-05-17 14:46:22.058039-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	7c8f68a2-0486-4be1-9ce6-b0573cfa593b	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:46:22.058037-03	\N
ebca74ad-a8dc-4832-977a-f3c879359c51	sdfsdf	1	2026-05-17 14:46:23.631743-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	88d119e5-b886-4ad3-92e5-6e11b90602cb	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:46:23.631739-03	\N
70c59fa7-da98-470a-b554-a3cebe33a7a8	sdfsdfsd	1	2026-05-17 14:46:25.070085-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	93d29867-c2e4-48c1-8e67-01abd9959ab0	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:46:25.070082-03	\N
e713fce4-6c7a-4ff9-ab42-af0daf88058c	sdfsdf	1	2026-05-17 14:46:26.993204-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	9b4c98ee-47c0-4a6e-84af-a3643c40f7f5	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:46:26.993201-03	\N
e62c39a3-0733-40dc-899a-52b8b723a9ee	sdfsdfsdf	1	2026-05-17 14:46:28.663547-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	ca2d24bf-8580-4e4b-9369-e9049c3cf446	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:46:28.663545-03	\N
163f647d-7713-446d-9d97-4b3293917d43	sdfsdfsdf	1	2026-05-17 14:46:30.980499-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	da78b5f7-acfd-4b32-90f1-126a48f3f3a5	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:46:30.980495-03	\N
c0ec4a4f-97a7-411b-a18c-a89fae97f25c	sdfsdfsdf	1	2026-05-17 14:46:33.161077-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	dc571716-745f-479f-8fee-2b8aee50c95e	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:46:33.161074-03	\N
dc094fac-f46a-4df4-95cc-9529ff976f9a	sdfsdfsdf	1	2026-05-17 14:46:35.768985-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	ee88bf75-837f-4101-a815-8bae343a90df	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:46:35.768981-03	\N
71cf7200-0faf-4414-b5ef-44a8a7216667	asdsad	1	2026-05-17 18:54:21.162434-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	0cf10c57-eed8-48d8-bd04-e06a2d9b72d2	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 18:54:21.162286-03	\N
08b3362f-a522-403d-b44e-150a62dca7a0	sddsd	1	2026-05-17 18:54:49.990147-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	b9ec1dcf-67d0-403e-991d-6e35883a5a7a	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 18:54:49.990144-03	\N
86d9d88f-6047-4dc9-a4a9-c7e7621aca3a	sdsdsd	1	2026-05-17 18:54:51.435903-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	b4bad7ee-7405-423f-9deb-819e5017b28d	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 18:54:51.4359-03	\N
c661915b-3ec6-47f1-8088-c955aa04a935	sdsdsdsd	1	2026-05-17 18:54:53.642237-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	a541d2a2-8fcc-4186-90e9-b5576a8c8b22	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 18:54:53.642236-03	\N
62e2d2ee-b7e2-4ede-b795-e0f976a8c98b	sdsdsdsd	1	2026-05-17 18:54:55.380014-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	9eeabf11-58d4-4c6a-a61b-5720288d14dc	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 18:54:55.380012-03	\N
0941179e-a637-4390-9261-ce85aba17858	sddsdsd	1	2026-05-17 19:57:13.598441-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	8544b3dd-12a1-470c-a5bc-07362927811f	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 19:57:13.597555-03	\N
4b813859-8d82-4ea4-a32d-d8b8ae8d4cb0	sgsgfgdedfg	1	2026-05-18 09:09:56.961962-03	\N	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	40b41741-df3e-4198-8080-dfa86bcb82a6	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-18 09:09:56.961242-03	\N
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders ("Id", "UserId", "ProductId", "Quantity", "TotalPrice", "Status", "Notes", "CreatedAt", "UpdatedAt", "ActivationEmail", "DeliveryActive") FROM stdin;
4ec75f42-6fac-475c-92a1-b129b1bde9c1	019e3644-d678-723c-9007-bcc56383c267	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	hghgh	2026-05-17 11:09:27.480052-03	2026-05-17 14:32:12.276651-03	\N	f
dc70833f-525a-4050-a245-0b967f7cc627	019e3644-d678-723c-9007-bcc56383c267	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 11:09:12.759628-03	2026-05-17 14:33:04.21754-03	\N	f
c553a342-adca-498d-8aa6-49f253adf8a3	019e3644-d678-723c-9007-bcc56383c267	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 11:09:18.485759-03	2026-05-17 14:39:48.895274-03	\N	f
387e8e75-696d-45b9-89a6-fa95d826f07f	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:40:39.923031-03	2026-05-17 14:46:18.57806-03	\N	f
6a5a91ea-1d22-4d58-93d0-67c47ec2c36d	019e27a2-023c-7bd4-b72b-9408ae963ebd	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	4	800.00	2	\N	2026-05-17 11:36:47.364311-03	2026-05-17 14:46:20.301891-03	\N	f
7c8f68a2-0486-4be1-9ce6-b0573cfa593b	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:40:38.233014-03	2026-05-17 14:46:22.058636-03	\N	f
88d119e5-b886-4ad3-92e5-6e11b90602cb	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:40:38.169652-03	2026-05-17 14:46:23.632978-03	\N	f
93d29867-c2e4-48c1-8e67-01abd9959ab0	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:40:39.994781-03	2026-05-17 14:46:25.071645-03	\N	f
9b4c98ee-47c0-4a6e-84af-a3643c40f7f5	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:40:38.254854-03	2026-05-17 14:46:26.994103-03	\N	f
ca2d24bf-8580-4e4b-9369-e9049c3cf446	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:40:39.959164-03	2026-05-17 14:46:28.664384-03	\N	f
da78b5f7-acfd-4b32-90f1-126a48f3f3a5	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:40:38.2071-03	2026-05-17 14:46:30.982111-03	\N	f
dc571716-745f-479f-8fee-2b8aee50c95e	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	4	800.00	2	34545	2026-05-17 13:34:28.810176-03	2026-05-17 14:46:33.161705-03	\N	f
ee88bf75-837f-4101-a815-8bae343a90df	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:40:39.873489-03	2026-05-17 14:46:35.769513-03	\N	f
0cf10c57-eed8-48d8-bd04-e06a2d9b72d2	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:47:10.351093-03	2026-05-17 18:54:21.209713-03	\N	f
b9ec1dcf-67d0-403e-991d-6e35883a5a7a	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:47:10.327586-03	2026-05-17 18:54:49.992663-03	\N	f
b4bad7ee-7405-423f-9deb-819e5017b28d	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:47:10.393226-03	2026-05-17 18:54:51.436911-03	\N	f
a541d2a2-8fcc-4186-90e9-b5576a8c8b22	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:47:10.370135-03	2026-05-17 18:54:53.642753-03	\N	f
9eeabf11-58d4-4c6a-a61b-5720288d14dc	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	200.00	2	\N	2026-05-17 14:47:10.300378-03	2026-05-17 18:54:55.380968-03	\N	f
8544b3dd-12a1-470c-a5bc-07362927811f	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	180.00	2	\N	2026-05-17 18:55:27.936233-03	2026-05-17 19:57:13.684197-03	\N	f
d7cdddaf-bb2d-4480-a137-02aad174b5a9	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	180.00	0	\N	2026-05-18 09:07:13.776625-03	\N	\N	f
40b41741-df3e-4198-8080-dfa86bcb82a6	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	3a28d1c1-5260-4da6-a82e-ec0bd3b08853	1	180.00	2	\N	2026-05-17 18:55:27.881805-03	2026-05-18 09:09:56.971644-03	\N	f
3a233cc4-b53a-41c9-9f20-e886fc8897e7	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	e0ed3d8b-a1d4-424b-a828-243064387e92	1	180.00	2	Entrega por ativacao confirmada no admin.	2026-05-22 23:12:05.552715-03	2026-05-22 23:19:43.877556-03	cliente@email.com	t
b49ebd4d-22f5-4b82-b4d7-adf2ba9544cd	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	e0ed3d8b-a1d4-424b-a828-243064387e92	1	180.00	0	\N	2026-05-22 23:23:43.059234-03	\N	se7edmnd@outlook.com	f
8dbcf8f5-be64-4c12-8de6-85334492be7e	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	e0ed3d8b-a1d4-424b-a828-243064387e92	1	180.00	2	Entrega por ativacao confirmada no admin.	2026-05-22 23:23:43.096524-03	2026-05-22 23:26:02.817048-03	se7edmnd@outlook.com	t
3058ac88-e62e-43f7-9384-9e5973888b16	019e27a2-023c-7bd4-b72b-9408ae963ebd	e0ed3d8b-a1d4-424b-a828-243064387e92	1	180.00	0	\N	2026-05-23 12:33:03.174564-03	\N	se7edmnd@outlook.com	f
\.


--
-- Data for Name: outbox_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.outbox_messages ("Id", "Type", "Payload", "OccurredAt", "ProcessedAt", "Error", "CreatedAt", "UpdatedAt") FROM stdin;
1c4693cd-6e9d-4921-a912-fde92a36f162	OrderCreatedIntegrationEvent	{"userId": "019e3644-d678-723c-9007-bcc56383c267", "orderId": "dc70833f-525a-4050-a245-0b967f7cc627", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T14:09:12.8036818Z", "totalPrice": 200.00}	2026-05-17 11:09:12.81071-03	\N	\N	2026-05-17 11:09:12.805673-03	\N
b82021ac-6307-4927-8d58-7cca79549102	OrderCreatedIntegrationEvent	{"userId": "019e3644-d678-723c-9007-bcc56383c267", "orderId": "c553a342-adca-498d-8aa6-49f253adf8a3", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T14:09:18.4864423Z", "totalPrice": 200.00}	2026-05-17 11:09:18.486673-03	\N	\N	2026-05-17 11:09:18.4865-03	\N
d79e9e7a-01a2-4aea-b32f-4575e9ffd4b3	OrderCreatedIntegrationEvent	{"userId": "019e3644-d678-723c-9007-bcc56383c267", "orderId": "4ec75f42-6fac-475c-92a1-b129b1bde9c1", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T14:09:27.4805892Z", "totalPrice": 200.00}	2026-05-17 11:09:27.4807-03	\N	\N	2026-05-17 11:09:27.480597-03	\N
91e2d35a-f3c6-4526-a821-0871fa2d28e2	OrderCreatedIntegrationEvent	{"userId": "019e27a2-023c-7bd4-b72b-9408ae963ebd", "orderId": "6a5a91ea-1d22-4d58-93d0-67c47ec2c36d", "quantity": 4, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T14:36:47.3665497Z", "totalPrice": 800.00}	2026-05-17 11:36:47.367704-03	\N	\N	2026-05-17 11:36:47.366616-03	\N
c91cf33b-e25d-4c5d-8182-91d194f7f49d	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "dc571716-745f-479f-8fee-2b8aee50c95e", "quantity": 4, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T16:34:28.8894908Z", "totalPrice": 800.00}	2026-05-17 13:34:28.899319-03	\N	\N	2026-05-17 13:34:28.891684-03	\N
51a5580b-098e-4f99-8026-c3b95ef43c1c	LicenseDeliveredIntegrationEvent	{"userId": "019e3644-d678-723c-9007-bcc56383c267", "orderId": "4ec75f42-6fac-475c-92a1-b129b1bde9c1", "licenseId": "ef054b44-96ff-4d97-abf9-0cc3e1bcd977", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:32:12.2705962Z"}	2026-05-17 14:32:12.275371-03	\N	\N	2026-05-17 14:32:12.271031-03	\N
6d41be66-9b25-4119-a4c6-444f9df47217	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "dc571716-745f-479f-8fee-2b8aee50c95e", "licenseId": "08169c43-77e6-458f-b3d4-95fa4ec16d88", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:33:01.3720269Z"}	2026-05-17 14:33:01.372097-03	\N	\N	2026-05-17 14:33:01.372033-03	\N
33c59751-a1ac-4b9d-89f8-a7f97e236aaa	LicenseDeliveredIntegrationEvent	{"userId": "019e3644-d678-723c-9007-bcc56383c267", "orderId": "dc70833f-525a-4050-a245-0b967f7cc627", "licenseId": "9dce5bef-ca16-4385-bd62-bb368f3cb6b8", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:33:04.2173374Z"}	2026-05-17 14:33:04.217409-03	\N	\N	2026-05-17 14:33:04.217344-03	\N
23a06745-a5f9-4cb7-8654-149b347ebb81	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "dc571716-745f-479f-8fee-2b8aee50c95e", "licenseId": "d91da00c-d28c-4f2d-be1f-79057a03badc", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:33:07.4885254Z"}	2026-05-17 14:33:07.488611-03	\N	\N	2026-05-17 14:33:07.488536-03	\N
7d92985d-c130-4ceb-ba48-bb2116275773	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "dc571716-745f-479f-8fee-2b8aee50c95e", "licenseId": "b380949b-079a-45e4-894d-350d901dc24a", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:33:12.2924126Z"}	2026-05-17 14:33:12.292529-03	\N	\N	2026-05-17 14:33:12.292416-03	\N
539b4f49-caae-4145-87d7-b5db5aac255f	LicenseDeliveredIntegrationEvent	{"userId": "019e3644-d678-723c-9007-bcc56383c267", "orderId": "c553a342-adca-498d-8aa6-49f253adf8a3", "licenseId": "b6446dc4-4a66-42bb-a10e-28790354749e", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:39:48.8946716Z"}	2026-05-17 14:39:48.894868-03	\N	\N	2026-05-17 14:39:48.894761-03	\N
a54fca61-4888-4f21-9a1f-564acb2f6289	LicenseDeliveredIntegrationEvent	{"userId": "019e27a2-023c-7bd4-b72b-9408ae963ebd", "orderId": "6a5a91ea-1d22-4d58-93d0-67c47ec2c36d", "licenseId": "31b7f21a-80d0-41d1-92cc-4ae184309971", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:39:51.0744858Z"}	2026-05-17 14:39:51.074582-03	\N	\N	2026-05-17 14:39:51.074493-03	\N
f49451bc-59b5-46c4-bb83-38f57cfa9d6b	LicenseDeliveredIntegrationEvent	{"userId": "019e27a2-023c-7bd4-b72b-9408ae963ebd", "orderId": "6a5a91ea-1d22-4d58-93d0-67c47ec2c36d", "licenseId": "f1f5c8c1-09db-474d-b744-1e283f491ec7", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:39:52.9733266Z"}	2026-05-17 14:39:52.973387-03	\N	\N	2026-05-17 14:39:52.973333-03	\N
625908df-df11-49bb-bc31-9a82d1eb4549	LicenseDeliveredIntegrationEvent	{"userId": "019e27a2-023c-7bd4-b72b-9408ae963ebd", "orderId": "6a5a91ea-1d22-4d58-93d0-67c47ec2c36d", "licenseId": "3ae0c7f9-24e2-47c1-a11e-41b3d1c9dd10", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:39:54.7947684Z"}	2026-05-17 14:39:54.79494-03	\N	\N	2026-05-17 14:39:54.79478-03	\N
23413f62-60e3-4281-b9b5-f64ca43ec643	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "88d119e5-b886-4ad3-92e5-6e11b90602cb", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:40:38.1717112Z", "totalPrice": 200.00}	2026-05-17 14:40:38.172035-03	\N	\N	2026-05-17 14:40:38.171899-03	\N
bb92f54c-5886-4097-b923-75882863f296	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "da78b5f7-acfd-4b32-90f1-126a48f3f3a5", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:40:38.2076168Z", "totalPrice": 200.00}	2026-05-17 14:40:38.207713-03	\N	\N	2026-05-17 14:40:38.207623-03	\N
db7912cc-b001-4334-bcc0-92b40974229a	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "7c8f68a2-0486-4be1-9ce6-b0573cfa593b", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:40:38.2334487Z", "totalPrice": 200.00}	2026-05-17 14:40:38.233526-03	\N	\N	2026-05-17 14:40:38.233455-03	\N
1bc5fa4d-fb06-4e7f-a777-22355d53bfc1	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "9b4c98ee-47c0-4a6e-84af-a3643c40f7f5", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:40:38.2551594Z", "totalPrice": 200.00}	2026-05-17 14:40:38.255229-03	\N	\N	2026-05-17 14:40:38.255165-03	\N
bce582f1-ae76-4550-9c13-6245d98aed3d	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "ee88bf75-837f-4101-a815-8bae343a90df", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:40:39.873904Z", "totalPrice": 200.00}	2026-05-17 14:40:39.873998-03	\N	\N	2026-05-17 14:40:39.87391-03	\N
2357d6d6-64da-4631-8f35-5fe36490e05b	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "387e8e75-696d-45b9-89a6-fa95d826f07f", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:40:39.9234621Z", "totalPrice": 200.00}	2026-05-17 14:40:39.923557-03	\N	\N	2026-05-17 14:40:39.923468-03	\N
9b5ee109-2e5e-4670-8420-672a20a1ae28	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "ca2d24bf-8580-4e4b-9369-e9049c3cf446", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:40:39.9596028Z", "totalPrice": 200.00}	2026-05-17 14:40:39.959695-03	\N	\N	2026-05-17 14:40:39.95961-03	\N
9ea53650-1474-48be-987b-17a7665af2a5	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "93d29867-c2e4-48c1-8e67-01abd9959ab0", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:40:39.9952607Z", "totalPrice": 200.00}	2026-05-17 14:40:39.995372-03	\N	\N	2026-05-17 14:40:39.99527-03	\N
12a74199-5e72-4fa7-958c-2e2bd02dea12	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "387e8e75-696d-45b9-89a6-fa95d826f07f", "licenseId": "f2bb36c6-edd4-4252-a9a6-13057528f898", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:46:18.5776727Z"}	2026-05-17 14:46:18.577811-03	\N	\N	2026-05-17 14:46:18.577687-03	\N
2f31920f-8b99-4685-b17d-eede70079511	LicenseDeliveredIntegrationEvent	{"userId": "019e27a2-023c-7bd4-b72b-9408ae963ebd", "orderId": "6a5a91ea-1d22-4d58-93d0-67c47ec2c36d", "licenseId": "4f6d636e-a3ef-4a4a-aacd-6adb13e09fdc", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:46:20.3016659Z"}	2026-05-17 14:46:20.301763-03	\N	\N	2026-05-17 14:46:20.301672-03	\N
639d99b8-275c-4ef2-aadf-5b488bd41fb7	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "7c8f68a2-0486-4be1-9ce6-b0573cfa593b", "licenseId": "eb78881a-ba45-40c2-bd62-87166b341809", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:46:22.0584176Z"}	2026-05-17 14:46:22.058492-03	\N	\N	2026-05-17 14:46:22.058427-03	\N
1d2109a5-5b49-4929-9c67-e500cd384011	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "88d119e5-b886-4ad3-92e5-6e11b90602cb", "licenseId": "ebca74ad-a8dc-4832-977a-f3c879359c51", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:46:23.6325759Z"}	2026-05-17 14:46:23.632705-03	\N	\N	2026-05-17 14:46:23.632586-03	\N
0631b37c-d2e1-4cbf-9480-4d00eba67686	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "93d29867-c2e4-48c1-8e67-01abd9959ab0", "licenseId": "70c59fa7-da98-470a-b554-a3cebe33a7a8", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:46:25.0709003Z"}	2026-05-17 14:46:25.071447-03	\N	\N	2026-05-17 14:46:25.071174-03	\N
b174c73a-b38e-4c7d-aaf1-7445463f3778	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "9b4c98ee-47c0-4a6e-84af-a3643c40f7f5", "licenseId": "e713fce4-6c7a-4ff9-ab42-af0daf88058c", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:46:26.9936987Z"}	2026-05-17 14:46:26.993822-03	\N	\N	2026-05-17 14:46:26.99371-03	\N
5a979ca3-db9c-4881-95c6-d6fb60598b56	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "ca2d24bf-8580-4e4b-9369-e9049c3cf446", "licenseId": "e62c39a3-0733-40dc-899a-52b8b723a9ee", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:46:28.664033Z"}	2026-05-17 14:46:28.66415-03	\N	\N	2026-05-17 14:46:28.664071-03	\N
a1832788-fc38-4d54-bbc2-5d0b2eaf496f	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "da78b5f7-acfd-4b32-90f1-126a48f3f3a5", "licenseId": "163f647d-7713-446d-9d97-4b3293917d43", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:46:30.9813535Z"}	2026-05-17 14:46:30.981485-03	\N	\N	2026-05-17 14:46:30.981367-03	\N
0452a4fb-5344-4c7e-9185-3cf4ee6945f4	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "dc571716-745f-479f-8fee-2b8aee50c95e", "licenseId": "c0ec4a4f-97a7-411b-a18c-a89fae97f25c", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:46:33.161537Z"}	2026-05-17 14:46:33.161591-03	\N	\N	2026-05-17 14:46:33.161542-03	\N
5e61de29-30e2-4c74-8186-9d6482f0ec3e	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "ee88bf75-837f-4101-a815-8bae343a90df", "licenseId": "dc094fac-f46a-4df4-95cc-9529ff976f9a", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:46:35.7693722Z"}	2026-05-17 14:46:35.769422-03	\N	\N	2026-05-17 14:46:35.769377-03	\N
718bc320-bcb0-4af6-bd39-17084d1bb87b	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "9eeabf11-58d4-4c6a-a61b-5720288d14dc", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:47:10.300919Z", "totalPrice": 200.00}	2026-05-17 14:47:10.301031-03	\N	\N	2026-05-17 14:47:10.300929-03	\N
2aa9fbb9-b5f3-4789-8eaf-16b689974d16	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "b9ec1dcf-67d0-403e-991d-6e35883a5a7a", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:47:10.3279757Z", "totalPrice": 200.00}	2026-05-17 14:47:10.328048-03	\N	\N	2026-05-17 14:47:10.327979-03	\N
f94114a6-6608-4277-b2b3-0cbce9ce9171	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "0cf10c57-eed8-48d8-bd04-e06a2d9b72d2", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:47:10.3515455Z", "totalPrice": 200.00}	2026-05-17 14:47:10.351629-03	\N	\N	2026-05-17 14:47:10.351552-03	\N
c1d562ac-2737-4079-a6f7-2a1271a3ea68	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "a541d2a2-8fcc-4186-90e9-b5576a8c8b22", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:47:10.370336Z", "totalPrice": 200.00}	2026-05-17 14:47:10.370386-03	\N	\N	2026-05-17 14:47:10.370339-03	\N
c532625d-06fb-4273-a4a8-5ffb9d522c88	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "b4bad7ee-7405-423f-9deb-819e5017b28d", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T17:47:10.3936744Z", "totalPrice": 200.00}	2026-05-17 14:47:10.3938-03	\N	\N	2026-05-17 14:47:10.393681-03	\N
0bf611d7-b760-45ad-9ded-c1ae96e70fea	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "0cf10c57-eed8-48d8-bd04-e06a2d9b72d2", "licenseId": "71cf7200-0faf-4414-b5ef-44a8a7216667", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T21:54:21.1905354Z"}	2026-05-17 18:54:21.193988-03	\N	\N	2026-05-17 18:54:21.191474-03	\N
8ddabc55-0818-44a2-81ef-734a82462eef	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "b9ec1dcf-67d0-403e-991d-6e35883a5a7a", "licenseId": "08b3362f-a522-403d-b44e-150a62dca7a0", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T21:54:49.9916453Z"}	2026-05-17 18:54:49.992363-03	\N	\N	2026-05-17 18:54:49.991747-03	\N
22443546-e637-4537-b15f-2e315efce615	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "b4bad7ee-7405-423f-9deb-819e5017b28d", "licenseId": "86d9d88f-6047-4dc9-a4a9-c7e7621aca3a", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T21:54:51.436366Z"}	2026-05-17 18:54:51.436599-03	\N	\N	2026-05-17 18:54:51.436396-03	\N
415afe36-8c3c-49e3-b736-c62d6951dec1	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "a541d2a2-8fcc-4186-90e9-b5576a8c8b22", "licenseId": "c661915b-3ec6-47f1-8088-c955aa04a935", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T21:54:53.6425677Z"}	2026-05-17 18:54:53.642621-03	\N	\N	2026-05-17 18:54:53.642571-03	\N
6699b492-83f3-40eb-a926-0c30b3b71fa5	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "9eeabf11-58d4-4c6a-a61b-5720288d14dc", "licenseId": "62e2d2ee-b7e2-4ede-b795-e0f976a8c98b", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T21:54:55.3805029Z"}	2026-05-17 18:54:55.380631-03	\N	\N	2026-05-17 18:54:55.380513-03	\N
2f822ca0-3cb5-48b4-9c68-cfb95f99fd29	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "40b41741-df3e-4198-8080-dfa86bcb82a6", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T21:55:27.8831682Z", "totalPrice": 180.00}	2026-05-17 18:55:27.885024-03	\N	\N	2026-05-17 18:55:27.883405-03	\N
7e64d2af-6907-45f4-a7f1-5d013e081142	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "8544b3dd-12a1-470c-a5bc-07362927811f", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T21:55:27.9365058Z", "totalPrice": 180.00}	2026-05-17 18:55:27.936562-03	\N	\N	2026-05-17 18:55:27.936509-03	\N
3aabbae1-345e-48e1-b38f-d203980710e6	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "8544b3dd-12a1-470c-a5bc-07362927811f", "licenseId": "0941179e-a637-4390-9261-ce85aba17858", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-17T22:57:13.6634518Z"}	2026-05-17 19:57:13.668313-03	\N	\N	2026-05-17 19:57:13.664777-03	\N
574fb497-7699-4541-815b-e4e2f224657c	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "d7cdddaf-bb2d-4480-a137-02aad174b5a9", "quantity": 1, "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-18T12:07:13.863465Z", "totalPrice": 180.00}	2026-05-18 09:07:13.872959-03	\N	\N	2026-05-18 09:07:13.865611-03	\N
bac2c15e-9522-4e5b-8967-c75c75e0d4d5	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "40b41741-df3e-4198-8080-dfa86bcb82a6", "licenseId": "4b813859-8d82-4ea4-a32d-d8b8ae8d4cb0", "productId": "3a28d1c1-5260-4da6-a82e-ec0bd3b08853", "occurredAt": "2026-05-18T12:09:56.9666611Z"}	2026-05-18 09:09:56.971231-03	\N	\N	2026-05-18 09:09:56.967142-03	\N
194717f8-8055-45fe-8ecb-de4d44b8e356	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "3a233cc4-b53a-41c9-9f20-e886fc8897e7", "quantity": 1, "productId": "e0ed3d8b-a1d4-424b-a828-243064387e92", "occurredAt": "2026-05-23T02:12:05.5691928Z", "totalPrice": 180.00}	2026-05-22 23:12:05.573738-03	\N	\N	2026-05-22 23:12:05.570471-03	\N
f8778b2b-3b1d-4f33-8aba-f826bbc37ae3	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "3a233cc4-b53a-41c9-9f20-e886fc8897e7", "licenseId": "00000000-0000-0000-0000-000000000000", "productId": "e0ed3d8b-a1d4-424b-a828-243064387e92", "occurredAt": "2026-05-23T02:19:43.8775588Z"}	2026-05-22 23:19:43.880306-03	\N	\N	2026-05-22 23:19:43.877831-03	\N
4719dfd2-7d93-4702-9781-d0b76c2befde	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "b49ebd4d-22f5-4b82-b4d7-adf2ba9544cd", "quantity": 1, "productId": "e0ed3d8b-a1d4-424b-a828-243064387e92", "occurredAt": "2026-05-23T02:23:43.0607109Z", "totalPrice": 180.00}	2026-05-22 23:23:43.06099-03	\N	\N	2026-05-22 23:23:43.06078-03	\N
fa606bd1-1f79-4928-85f5-1885a36cfd0e	OrderCreatedIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "8dbcf8f5-be64-4c12-8de6-85334492be7e", "quantity": 1, "productId": "e0ed3d8b-a1d4-424b-a828-243064387e92", "occurredAt": "2026-05-23T02:23:43.0967428Z", "totalPrice": 180.00}	2026-05-22 23:23:43.097529-03	\N	\N	2026-05-22 23:23:43.096749-03	\N
196a49cc-83ae-436a-b61e-3569bf550e5a	LicenseDeliveredIntegrationEvent	{"userId": "019e2b98-51b2-7573-91f4-aa5fd96dd5d3", "orderId": "8dbcf8f5-be64-4c12-8de6-85334492be7e", "licenseId": "00000000-0000-0000-0000-000000000000", "productId": "e0ed3d8b-a1d4-424b-a828-243064387e92", "occurredAt": "2026-05-23T02:26:02.8170547Z"}	2026-05-22 23:26:02.817218-03	\N	\N	2026-05-22 23:26:02.817066-03	\N
ec5fc49f-d42b-4e01-9310-9a0e999238c6	OrderCreatedIntegrationEvent	{"userId": "019e27a2-023c-7bd4-b72b-9408ae963ebd", "orderId": "3058ac88-e62e-43f7-9384-9e5973888b16", "quantity": 1, "productId": "e0ed3d8b-a1d4-424b-a828-243064387e92", "occurredAt": "2026-05-23T15:33:03.1920978Z", "totalPrice": 180.00}	2026-05-23 12:33:03.203073-03	\N	\N	2026-05-23 12:33:03.193143-03	\N
41a1924a-7ca7-42ef-b309-656e1c75f157	PaymentCreatedIntegrationEvent	{"amount": 180.00, "status": 0, "orderId": "3058ac88-e62e-43f7-9384-9e5973888b16", "currency": "BRL", "platform": 0, "paymentId": "a85e5198-fcd7-4c53-a5df-7a53b90a5b43", "occurredAt": "2026-05-23T15:33:03.5239219Z", "externalPaymentId": "sim_3058ac88e62e43f793849e5973888b16_1779550383496"}	2026-05-23 12:33:03.527514-03	\N	\N	2026-05-23 12:33:03.524111-03	\N
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments ("Id", "OrderId", "Platform", "Status", "Amount", "Currency", "ExternalPaymentId", "CheckoutUrl", "FailureReason", "CreatedAt", "UpdatedAt") FROM stdin;
13ccc8fa-8d63-4899-b707-7bf13cb819f1	8544b3dd-12a1-470c-a5bc-07362927811f	0	2	180.00	brl	sdsds	sdsds	sdsdsd	2026-05-17 19:29:13.299463-03	2026-05-17 19:29:13.301266-03
d9d4d6dd-c639-49cb-b196-db67bfdbde97	40b41741-df3e-4198-8080-dfa86bcb82a6	0	2	180.00	brl	sdsds	sdsds	sdsdsd	2026-05-18 09:09:22.333282-03	2026-05-18 09:09:22.396799-03
2a361aa3-7118-4153-a3a5-bb3d03da83e4	3a233cc4-b53a-41c9-9f20-e886fc8897e7	0	2	180.00	1	string	string	string	2026-05-22 23:19:10.153691-03	2026-05-22 23:19:10.1545-03
1fbb48c3-b256-4ec7-ae4d-c18980ecd21c	8dbcf8f5-be64-4c12-8de6-85334492be7e	0	2	180.00	1	string	string	string	2026-05-22 23:24:19.670047-03	2026-05-22 23:24:19.670936-03
a85e5198-fcd7-4c53-a5df-7a53b90a5b43	3058ac88-e62e-43f7-9384-9e5973888b16	0	0	180.00	BRL	sim_3058ac88e62e43f793849e5973888b16_1779550383496	http://localhost:3000/checkout/success?orderId=3058ac88-e62e-43f7-9384-9e5973888b16	\N	2026-05-23 12:33:03.497682-03	\N
\.


--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_images ("Id", "ProductId", "Url", "AltText", "SortOrder", "IsPrimary", "CreatedAt", "UpdatedAt") FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products ("Id", "Name", "Description", "Price", "CreatedAt", "UpdatedAt", "ShortDescription", "Active", "BrandId", "CategoryId", "PromotionalPrice", "Slug", "DeliveryType", "RequiresActivationEmail", "PrimaryImageId") FROM stdin;
3a28d1c1-5260-4da6-a82e-ec0bd3b08853	Windows 10 pro	Windows 10 pro licença vitalicia	200.00	2026-05-14 18:45:47.084916-03	2026-05-17 13:14:33.833833-03	Licença vitalicia	t	58fba2af-0cd9-4b5b-bebd-d1911727b33a	4f3d10bc-4ed2-468d-83a6-8aad927784c8	180.00	Windows-Company	0	f	\N
e0ed3d8b-a1d4-424b-a828-243064387e92	autodesk	Licença vitalícia autodesk	200.00	2026-05-22 23:09:57.770679-03	2026-05-25 08:52:19.308183-03	licença autodesk	t	61cbe764-3a50-4aa7-9854-155c59859ef3	2aad6332-43b3-46e5-ab61-e2aa7afc5d9c	180.00	autodesk-company	1	t	\N
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens ("Id", "Token", "ExpiresAt", "RevokedAt", "UserId", "CreatedAt", "UpdatedAt") FROM stdin;
0b09dde9-5654-4b71-b9dc-b7c06730ea5a	WRrO74Yjc6KEvK2gvoAJ3ZAxFABWu91HUivFLNdDQFSP87rntSaqw0VCRjPET+/oqVzpxTqIyQ/cPf5wbBuPug==	2026-05-21 18:42:31.534837-03	2026-05-17 11:08:17.986051-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 18:42:31.534409-03	2026-05-17 11:08:17.986051-03
0be47df3-0f8e-4266-9636-b092b86e9506	iwTFBMDm/3LtkM4RgA5Xvnj/MGaqGWvTNAvf3WlNRLsvml0btBtlt+E2mIlBt9PB4jdnIav+DsBxyAuLmwE4AA==	2026-05-21 16:06:46.316369-03	2026-05-17 11:08:17.986047-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 16:06:46.316042-03	2026-05-17 11:08:17.986047-03
16951885-047f-4aab-92e4-cc89c6a364ea	K9z48nlMgJWgF4bniWwtS/8fsFuPC6SOjsMz0WGEv8RNUneQv2gpwCy8qvfQ//SUE30OmOOcAq8Qe4myxarb6w==	2026-05-23 21:45:03.959695-03	2026-05-17 11:08:17.986053-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-16 21:45:03.958987-03	2026-05-17 11:08:17.986053-03
302afaa9-43d2-4f38-894f-5debdf946c38	K9idQp+Qnczbim19DQUtZ1109uswlOHEmsbcCJnU4xWSeN9OscbUfgoKM+nngvC9L4rpwMu4SqoXXNLp8B5k2w==	2026-05-24 11:08:07.700327-03	2026-05-17 11:08:17.986054-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 11:08:07.699938-03	2026-05-17 11:08:17.986054-03
3161f5a5-4bb6-4b2d-87e4-9f2e451f748d	aZ8c9oXT7rRhXmTkNKdrioHGObCp9W0F3oS7a0j+rOn+N6LAKlHE2ps3nqtGDIutUmKTj2csq4rB31Wc74gKZQ==	2026-05-21 21:36:36.731938-03	2026-05-17 11:08:17.986051-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 21:36:36.731063-03	2026-05-17 11:08:17.986051-03
348fb7b1-d6f0-4ef0-8079-df95a0ae9882	S5KBIoUuYOPBQ/y1SaBMPu9TrL5djyi8J8wjDtcDLvK++qhhxtHkmkg4BoVF/qrJv2PL6pxwAgasBJ0xNxuvDg==	2026-05-22 09:25:33.421339-03	2026-05-17 11:08:17.986051-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-15 09:25:33.42126-03	2026-05-17 11:08:17.986051-03
380eb456-ba64-459e-8820-63faa50f4a96	2a/FCdGD9sLbEWREy1vOnARfqC/VIGyZ6RoI26dPb+q3I5qkcx6XPRVOFCvaEeR34CFRcw+PKn5vnlYrced3sg==	2026-05-23 22:41:56.195607-03	2026-05-17 11:08:17.986053-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-16 22:41:56.1956-03	2026-05-17 11:08:17.986054-03
54483d14-8cf1-4d0d-aec5-fdbf433d63f1	pTQkZszNcpUqqred2/tm27LnBuKxdoZsFFdL8wftmK2VBjzXSQL4TskeHa+F2jSYSurUdHGRGF5U91edV0Ktlg==	2026-05-21 16:15:23.645046-03	2026-05-17 11:08:17.986048-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 16:15:23.644871-03	2026-05-17 11:08:17.986048-03
55f180df-fd8e-47c0-bcbf-6e1d3b44f19d	taQqH0s+yhbUnX5U3qcr2CGtmFwpcdQ6+FkaSEgpSEZDCBIm0MkLAiDJn0Eoul7IxB07CJmzEgDBjOyvjgkQoA==	2026-05-21 18:12:29.400358-03	2026-05-17 11:08:17.98605-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 18:12:29.400296-03	2026-05-17 11:08:17.98605-03
5e75d72e-5a43-4262-bdd6-a05069b7bd2a	Gwa3nWcYZFZ9SRV5iFJbXR/gA9Svp6VB72MSRq+SQ6K06c532qpKnACV6D6kklKgRr6EqyIT2hWj1Twy1OrOew==	2026-05-21 16:33:34.220486-03	2026-05-17 11:08:17.986048-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 16:33:34.220054-03	2026-05-17 11:08:17.986048-03
6178a946-b9ee-456b-bca8-f5e5fba4bd69	cMNjnfTT4BfipTyYUwi/Wxy4It7fiFYmcHE/EAgWKE98x6qqHMr9ZcBwDt4WIXQvrKjC7OnwEGDRVFHUoNf2NQ==	2026-05-23 14:31:46.807167-03	2026-05-17 11:08:17.986053-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-16 14:31:46.806702-03	2026-05-17 11:08:17.986053-03
679102c4-74ea-4b07-9f86-706919180157	+M2POZjTXopWj6wD4Z4/LkYl6gdvRgoiCoHpyWr1U3QFsDnDfgKaIgI51s/ROM2DOjN1M/KOX3J1Yn+V2nMG+w==	2026-05-21 16:47:55.129086-03	2026-05-17 11:08:17.98605-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 16:47:55.128925-03	2026-05-17 11:08:17.98605-03
6ae5d954-0274-4fbc-95c4-d8a49c1c4e9a	dz3H3rRMydU1hGl+Z3guZ2iaKVo16vVLy8B2Wk0slHygoRn2S7f0/MSy7MxrPIDkeSC+27G0ekzyFk9E35thzA==	2026-05-22 10:03:46.241222-03	2026-05-17 11:08:17.986052-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-15 10:03:46.241204-03	2026-05-17 11:08:17.986052-03
4528a19b-9316-4449-a73f-5c55905c5955	fUMycvmwQWpWqC3yxdw1ID0mj7iKYaqMIDvfavENH/RjWf37CZSJhN+s3iuYBFXpBv31mPR2dY9lvMsCUh5YJg==	2026-05-23 22:31:54.372639-03	2026-05-17 13:57:28.832983-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-16 22:31:54.372622-03	2026-05-17 13:57:28.832983-03
9432966d-444a-437f-a66b-98d89a264b68	IrWMSThZSRbxQ5ofgfafCQlf0BM9l5KgCbE2Zb2SU3PkiJTMNLfgmG0UcescM0QismMcR3lWFpf9asbPyVBWAw==	2026-05-22 09:24:23.822875-03	2026-05-17 13:57:28.832979-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-15 09:24:23.822431-03	2026-05-17 13:57:28.832981-03
b302ce41-6d03-4e05-9618-d82fe4bf0c87	U+WW9d1JNuYtjI1sDwO9QedHpr9Z3PA4wcTq/SlAElz0ut09unzyw5XbbWZbkFp1EIH8KN1NpgS6T5eEY9EuNA==	2026-05-22 09:25:46.027504-03	2026-05-17 13:57:28.832982-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-15 09:25:46.027497-03	2026-05-17 13:57:28.832983-03
7154769c-4cd0-4282-9a91-3f7c7b088297	hmZcjaq/CMriEt7CISMP67ImVfLaJqXhZoWweo2UEbgrvSYj8tgd7ari9oGsc7xoaUSNdUCebR2bVkU/qv6n6g==	2026-05-21 16:38:45.345466-03	2026-05-17 11:08:17.986049-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 16:38:45.345341-03	2026-05-17 11:08:17.986049-03
82d2b270-1dcb-4740-8f9a-bfaa5ca2728b	ZnMGAd3kiXXRdi1IOd4ipTOGmbFo/8EoILZjmDzTt2NKthzkGSJ9h90iYMoNEGFjyKW+F0bealHvg8d39LVBuQ==	2026-05-21 16:35:17.546016-03	2026-05-17 11:08:17.986049-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 16:35:17.545677-03	2026-05-17 11:08:17.986049-03
8bd17ffe-b995-49bd-9b7e-dad55702e97f	8VWjGllFQTN1dpopnYz6c81p/MrKy/O4QZHP3xqvj3WFVlXlP8H2kbi78BX2fOmk0YRACYR9bW113Bk1DevS7g==	2026-05-21 20:11:35.987296-03	2026-05-17 11:08:17.986051-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 20:11:35.98683-03	2026-05-17 11:08:17.986051-03
9182ab3c-7fa1-4f10-85b7-0b280e93aea9	rLEa/Nq7yo5I5GSAyXZO6yw71EdXpJafXXvU90Jq24ucNR2V+Ox41G2leczbfrT/AzaLPUm7MK9Hs3HVCohtJQ==	2026-05-21 18:12:31.673097-03	2026-05-17 11:08:17.98605-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 18:12:31.67308-03	2026-05-17 11:08:17.98605-03
97fd1cf7-4a5e-427f-833e-d5ab9e97eab6	ojGwWO6GUrCdOMxfs5czcdJgA56gM5L8adIwXdDQEMigQCswlNmRKw3YXOza8ygCgEV/pCePyB+FHdiuFfgnvA==	2026-05-21 16:11:53.837557-03	2026-05-17 11:08:17.986047-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 16:11:53.837278-03	2026-05-17 11:08:17.986048-03
a5ba7244-6d8c-402a-88a8-d4d2b79330f9	PYRCdWT4Bx79T8d4AyBPhXcAhL4NfK0F90OXtaI8j5NqpHiP0bVT/J68rwaENIgHOfgYCPXc5bplYxcvi29U4w==	2026-05-22 15:08:41.341903-03	2026-05-17 11:08:17.986052-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-15 15:08:41.341892-03	2026-05-17 11:08:17.986052-03
a664c57d-3d3e-44fe-82a0-c36fae738908	wvAzD64Qq3i8V1L/s1U1QI2WJTy+JVtpzB6NpfcxqchlOYhwtQxJPwWyVnW51nwcPa3J77citjtud/oEmMWD6w==	2026-05-23 20:06:24.723262-03	2026-05-17 11:08:17.986053-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-16 20:06:24.722497-03	2026-05-17 11:08:17.986053-03
abc8c79f-0142-4046-be37-cb82a7815d9f	Lg1wzclQDIvWbKg7BRa24oz+h/yn8z4cvKi0o+DGevvaip0wgslu2Y26/41GIll31hAVe+xQlc7szLwrjhGlZQ==	2026-05-21 15:09:50.78969-03	2026-05-17 11:08:17.985672-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 15:09:50.788972-03	2026-05-17 11:08:17.985928-03
b6ee1b93-8ee6-49b9-8b6b-b5ebd9b95f3e	7cmYS6sba9M5aMvRbs+NAZ6536gMrEm1OXISZko7bDh+vJlOkvsk8uap7I4VNFGqtZU/omMdjWivUS+SwrdHkQ==	2026-05-21 16:42:57.401506-03	2026-05-17 11:08:17.986049-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 16:42:57.401298-03	2026-05-17 11:08:17.986049-03
c8a392f3-ff6f-4e58-880a-121db49255cc	gQuMsoRfTWNDQ98QlErMHUdTiaJ1r+0uqC9NcZ/xeg9BIvcsY8eQQybK2k0RVrTUf1aqloclnnIj++W59n8mmA==	2026-05-21 15:44:49.394292-03	2026-05-17 11:08:17.986046-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 15:44:49.393921-03	2026-05-17 11:08:17.986046-03
c8d999a7-6a9d-42bc-a2f4-39ac7977f666	bfRUX4Q1OU/ZgGdVXZYJzop6tdqJ3LIXlMbtSWydO2GERsh05g0zyj4G+xxuuntjNNX5+JSAXF14UxoRgssPkA==	2026-05-21 18:09:43.826641-03	2026-05-17 11:08:17.98605-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 18:09:43.826159-03	2026-05-17 11:08:17.98605-03
e6e41cd5-64a8-4861-99e0-ece60267cf74	lHDlt4+234Mw8sFMbvOySQV3jlNimBKTEeW6Duk6yysKcPTVu3S47FuRip+ku++5lhcc1/y3UCO5Wt1A3ynMGQ==	2026-05-21 16:04:11.423717-03	2026-05-17 11:08:17.986047-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 16:04:11.423455-03	2026-05-17 11:08:17.986047-03
f273c801-0b09-47e9-96e8-276bc6bb522c	kcum9cfoyXtDKJz3Pp5dfbsf87L4lbYuU8XZX8SX3zs252+bvXnnJJA8F32qJExDJXQYM2NnEEre+jXCDadTCQ==	2026-05-22 15:08:34.448126-03	2026-05-17 11:08:17.986052-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-15 15:08:34.448088-03	2026-05-17 11:08:17.986052-03
f3abd569-b1e9-45cc-98c0-01e8ebe26df4	XOJDRYOffj7vYIb7ossFkIeBHJUUsa+qA5zEHpnX+gCzB9LI+E+8f0HQ8CypyskrZH0WZQhcoR9LN7b+TqfOzQ==	2026-05-21 15:12:55.772101-03	2026-05-17 11:08:17.986045-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 15:12:55.771774-03	2026-05-17 11:08:17.986046-03
f6041c60-b605-4318-a3e0-545f8fbb7a3f	EGAgc7k9FawmHV+3Xv1DrwoKXlrHcge5vYV/aKNTdOTywcLnuL3SrmGvik3cWDR0g3lwYQl9ZCoebb3YHkxc8g==	2026-05-21 16:13:09.270418-03	2026-05-17 11:08:17.986048-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-14 16:13:09.270346-03	2026-05-17 11:08:17.986048-03
f8ec177e-caf3-4d3a-b4f9-c3f5c67efcd9	oMV/jAdcftubNoZqjE6CLse1Qpk9kNi+dy06O80BGA0VuALaF6oArlDSlmLSJQ6m1JVUofzcLD+5aANtNhNdwg==	2026-05-22 15:08:27.406818-03	2026-05-17 11:08:17.986052-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-15 15:08:27.406105-03	2026-05-17 11:08:17.986052-03
fdeb79c6-6b91-43d6-b37e-50f6c22eb745	zbzBLnLFQjEJ9yDgmrQzoYpGCAuJM85P4FiTKPl6SC0LEQouxLJO/oLj3y0l3TepDbz43JJiP7FG/h6tfvIvkA==	2026-05-22 15:34:16.672683-03	2026-05-17 11:08:17.986053-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-15 15:34:16.672276-03	2026-05-17 11:08:17.986053-03
6d2388ca-3ef7-4c61-9935-61a1078bc4b2	t1B42br28a8ypQ0ewMWB+v/wqc4rLFKe6Gy6CUMwR0TD66QSDcdjxaI0kq/XSeU1jeJnG9fx6z5+SUS3K1+idQ==	2026-05-24 11:09:01.673617-03	\N	019e3644-d678-723c-9007-bcc56383c267	2026-05-17 11:09:01.67359-03	\N
a3300147-338d-4e78-b5d4-a5a609c25d26	RJtor9tnhlTfJTV1q2raL0fakSB6IISkT4Yz+UtmIy+3R09dA79Ac2ZBy7iBMng4Z+oF7XWR0bd5K0JMhxjScQ==	2026-05-24 12:50:38.40501-03	2026-05-17 13:14:51.307063-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 12:50:38.405002-03	2026-05-17 13:14:51.307063-03
ec54703c-276b-4caf-8aee-440370c89618	11ivxIaUaOJX7Z7MzYpBSDynJTX1N6oLHQlO/9zfQGoV2D4j+0j7MromM4zaY+zzrWkW/nYJG5tVCEW0p2jipA==	2026-05-24 11:21:21.216153-03	2026-05-17 13:14:51.306908-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 11:21:21.216142-03	2026-05-17 13:14:51.307062-03
4d9382aa-e999-4629-a14a-37c4235f5df3	FAZARGsJjMuabdG+OJnIOqEahl3TZ847N7rZ0z6fIKzvw9PQ0y6nrR6XAtQhHwmaB7rbSdUi8yW9doc5b9N1qQ==	2026-05-24 13:14:57.629762-03	2026-05-17 13:15:03.340161-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 13:14:57.629331-03	2026-05-17 13:15:03.340163-03
245d738c-9be2-4710-ab6f-8399062b5c01	bBybjEpYIASRQb0RcVOwk9239VCWoWE5iN+Vgv5yaS3Wj79JoPE5xemt6ZrQV6BRiSObea9ovIdyS8F4KNlZnw==	2026-05-24 13:15:39.281884-03	2026-05-17 13:57:28.832984-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 13:15:39.281878-03	2026-05-17 13:57:28.832984-03
348c5e5c-c590-490d-a470-d90ece1b7bb4	eCiu1v99i8wi1KAFcJv7jA5NOZLMDFCJlEpkGshkHRehkz5lEhA2J4WBP2nuIEZkmH/YaNHQMfrIxCrUqJNYiw==	2026-05-24 13:15:08.995116-03	2026-05-17 13:57:28.832983-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 13:15:08.99508-03	2026-05-17 13:57:28.832983-03
480e6b14-a749-4419-8318-5f25e8939d7c	xOTYnqGZC3scKOsTL9HxLoZDFgmJUF6wL7+PjggEwqxJzXXgPaS3jYkSQQHxlE2lB5GyyN0oAPOZ3fRcaI+9Yg==	2026-05-24 13:15:35.51316-03	2026-05-17 13:57:28.832984-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 13:15:35.513149-03	2026-05-17 13:57:28.832984-03
eff5f75d-9ba0-40fe-a359-8ef880374faf	SZh3fbDaaNlRDHJvJnvcpQTEgaQ8RFuEOhZVWAaduGI9g+OLfvrcn9/3pFAYg8WMLThzLS0TrsFAfwA9wWh8/Q==	2026-05-24 13:15:14.530806-03	2026-05-17 13:57:28.832983-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 13:15:14.530799-03	2026-05-17 13:57:28.832984-03
9bd66b4d-2703-4bf5-9267-56626e27662c	QULAo8ZDsXO+zlBwLOz6hczvwUfHf3ioIEDZ4dcva5SkguPfls9anB4679E6eCUglZ/hWffdSx06XEnrf0jDtg==	2026-05-24 13:57:33.005069-03	2026-05-17 14:02:55.275935-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 13:57:33.005042-03	2026-05-17 14:02:55.275937-03
48269721-9c71-4f7b-b2e5-d22f2952911f	UxfzE88tSbnbzTVZU/gPMkfe5VyJTe7hAeadXuWuEz28hjbH/Dpt7u0f/5ZvzN0GEvAVeQf4DjgAlItrVqlJ/g==	2026-05-24 14:02:59.490207-03	2026-05-17 14:07:00.503877-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:02:59.490187-03	2026-05-17 14:07:00.503878-03
ecd031fd-f016-40b6-8617-dcca0664f25f	ChQq0wxRC8+XligFvL1GiJ2T0viJaeFca60FAMbEMIdqIBs5JwkdBZD1qx+H+oZ07vkTqliREO+rM8vgbqfSCQ==	2026-05-24 14:07:03.818167-03	2026-05-17 14:13:14.294658-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:07:03.818149-03	2026-05-17 14:13:14.29466-03
c598150e-1b06-43ea-a0a5-b4387cdd7b72	Khtq++SJWuv/dP6JmsJtyDBigTBibL4srsBBQB+yqy4rqTtATIMd2rI1ZGToT1bD+eEx/NSHcKfhYDsfIoTFew==	2026-05-24 14:13:31.007295-03	2026-05-17 14:14:03.962394-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:13:31.007287-03	2026-05-17 14:14:03.962395-03
589bed28-d839-4b13-b846-d80a3a16b6db	z7D5AWoYrps3ryks5lWPZfONix+e2LwJqBwW2x0y8JH07466AlRjoy6iFWStFwW8gGeZq5IX36zGafWHNvuJOQ==	2026-05-24 14:14:13.336487-03	2026-05-17 14:32:23.241795-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:14:13.336482-03	2026-05-17 14:32:23.241797-03
85a5eb25-768c-4198-9475-04d8a695e8ee	wpWRHmpMWMPZn6ycNp3AW+/yXLQoQjQq7v0H2k9PqEew+FW8naLHtPkjzJ+czu78Yv6DgK5Nok9/Gd32MnRadg==	2026-05-24 14:32:27.02494-03	2026-05-17 14:32:41.241004-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:32:27.024926-03	2026-05-17 14:32:41.241005-03
15497b8f-97cf-4916-bc73-0d3054b4c562	X9lfiFRKE8gGd9Tnvh0zMUB7ZYILhEwA7PNJAAHy5MvvSxsuU4LgBZfBijMCHNL8lZkIq0gbGwiM7RXSh4GlWg==	2026-05-24 14:32:44.652706-03	2026-05-17 14:33:18.836523-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:32:44.652699-03	2026-05-17 14:33:18.836524-03
d15336df-143a-4f94-8497-78f288a3fe96	1tEMez2TC0ubLyjr/FIZET8LgxEFBELWhg0EnW7xGFaZlqzJFeP580IQZ6k411me4i3/vUuZEIi1rAXX4os4mg==	2026-05-24 14:33:23.630601-03	2026-05-17 14:38:34.434594-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:33:23.63059-03	2026-05-17 14:38:34.434596-03
c8ddd2a1-fdee-400c-aaed-1c6c5db84806	JQwesIt9tKGrWqCQ7RB9gS3uX8QVKkjsZxmOUh/ivoF2H3tF2LxJn8kgTUmggNnYHKwWEUgCbhVkchOJ+Gyfeg==	2026-05-24 14:38:38.104334-03	2026-05-17 14:39:20.520566-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:38:38.104318-03	2026-05-17 14:39:20.520568-03
ac7ef65d-651a-45f4-b5db-a338084a4b90	XwMXTaXHnreHEGwAH1ZOf8jP/Kd1qIPVWGJutU8IooGN6zSJpaVQnlFFEzLb3TMSZp1MBKMy9UXSYgrHyhSSuA==	2026-05-24 14:39:28.481655-03	2026-05-17 14:40:12.058961-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:39:28.481647-03	2026-05-17 14:40:12.058962-03
345c8a81-8ab5-489c-be09-971a91c61351	EyHI9yl1vdl93G2pFV6hWCpIX+7dln6KwVZhlfAvkSXoZdpy0wddKXRyItpwaWFaRZJcT7Xf4wGTfMEHavs0wQ==	2026-05-24 14:40:15.152965-03	2026-05-17 14:40:58.846237-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:40:15.152923-03	2026-05-17 14:40:58.846238-03
c02efa48-cf1e-4375-9cc2-c59a1e4ef62f	jtPOl8B0CX8YR3ppdaR3m3+uBn9YlwaMQo7rUi+pg2Q2+eCQdA4letBZg67Gaarw+FQ4O+/kCrmlAKkNfwNeGg==	2026-05-24 14:41:03.321481-03	2026-05-17 14:46:39.322596-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:41:03.321474-03	2026-05-17 14:46:39.322597-03
75d939e1-1107-419c-a11e-5384d5b42695	lzL9lLjYWaBz1jPomwkc4NQqE4EpHvEpeL3oB7XtfijEQKDgswoZIHP10BDmz2iGT7NPLvunyMFsZLX7pqcj3w==	2026-05-24 14:46:43.124327-03	2026-05-17 14:47:20.162017-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 14:46:43.124319-03	2026-05-17 14:47:20.162019-03
50bb5c63-a733-471a-8032-51235854ad83	W++2hB+5JALYzgURzLy/CDZsku5m6vaWqcPu95hKCOhS0DcyqM5HzJpgNyarsezmBf+RL6t6ie4biXiMJpy3zA==	2026-05-24 14:47:22.930801-03	2026-05-17 18:54:57.57871-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 14:47:22.930788-03	2026-05-17 18:54:57.578867-03
dfd40935-98fe-4b68-8d24-dd0cdbe4c017	3GLh3vcPQ900jdMzJg3VlQhD6H0OIP+sOSR2ylb6Cjnvp+3aL0FfY6UAsev3yKPEP4Xk0/i11yOcS0YHgQpbJg==	2026-05-24 18:54:15.369483-03	2026-05-17 18:54:57.578868-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 18:54:15.36934-03	2026-05-17 18:54:57.578868-03
8cc7b86f-9575-4883-928b-363114af9727	0mVSWBwZvy1ToQ44hPlLFHvY1FFgyIKpcnV0vCITG+8LfFgdoSy/T20kZOPbQjlglUFGt1cN+nzuzoLRvffuNw==	2026-05-24 18:55:01.631157-03	2026-05-17 18:55:50.729782-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 18:55:01.631131-03	2026-05-17 18:55:50.729783-03
7b517994-ee21-4167-a984-c26dea24d1a4	peLWP6I9T8qQz26PvAyo9gUfHD40K85EwTyfkU5xQZyL8ibOiBia5d5D1Qz80LYrab/QrRY9wQPc1NyBsv91rg==	2026-05-24 18:55:56.706434-03	2026-05-17 19:57:45.526223-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 18:55:56.706425-03	2026-05-17 19:57:45.526334-03
197a9864-eaa5-4b7c-9370-53e9a47c3986	qt2Uvz/B1OTABTmDzWoGurT+YiZCy7AYoG0xQ97gvWbLpNzaCOydP0iQgZKnQZWLzCbU2c8D2Zh92WRi75vClA==	2026-05-24 19:24:28.346871-03	2026-05-17 19:57:45.526335-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 19:24:28.346533-03	2026-05-17 19:57:45.526335-03
84919be9-8bb8-484c-8d68-ff541c58cf68	4XGPq8jpRVgDqC1eyvyBFgUy9DLPa1oyvZjT78WcSvio1q/WeDmsE7hiLKF+ER+pKpYR5CxGfdXx7SllGzqmVw==	2026-05-24 19:57:53.074507-03	2026-05-18 09:07:23.598051-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-17 19:57:53.074356-03	2026-05-18 09:07:23.598497-03
d8e1a9e6-9e5b-4462-a295-8b036d04b98d	R8qr5vpPNq+LlxTz4TlzeG8hjgY+z3IAYavW/76c9VKXAwm8vU4NkitXYTbnWD4vNS4tv+nzTV1zgfz1K5ESxQ==	2026-05-25 09:06:40.17842-03	2026-05-18 09:07:23.598692-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-18 09:06:40.178231-03	2026-05-18 09:07:23.598693-03
1216c2b0-efad-4b4c-8edb-df1eaba76ab2	v/g6I5NMOy+ng23dyzUm62G6vxw/4aEJBKtZs+sl5RMlTeAFJvMbwHp6XFPL4l3Zszi+Q17Ij8JENiK6/eq1Cw==	2026-05-25 09:07:44.339137-03	2026-05-18 09:10:03.824523-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-18 09:07:44.339075-03	2026-05-18 09:10:03.824523-03
3d7f73cb-72e9-42cd-a05f-158001511279	JPVx3Sg5SzqmH6pvMJbA87hF9Op3ldilqiSazvnt4N5ofd1x8LSbEiaCZ8buFIbXl42eHiFp8D7ZaIHr/5E/+w==	2026-05-25 09:08:12.478981-03	2026-05-18 09:10:03.824523-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-18 09:08:12.478967-03	2026-05-18 09:10:03.824523-03
c0d4585d-39cf-4d1d-a57a-f152d5867849	iKT1sGLAIJ878aiTU1/uw7Lm6s31qqfbI4X5hgdoLPDfnoOUA3VXGSHq936aDkL/SbSaMYnI8gd7dBGT0YVCTQ==	2026-05-24 21:10:48.389321-03	2026-05-18 09:10:03.824522-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-17 21:10:48.389191-03	2026-05-18 09:10:03.824523-03
c681b213-902c-4126-a167-9bbe4508d727	9JwvcdmWD+bW3Kx8LFw2/2ZCW54rjUtRJwAN6cPxvA+dnTi5aOgs0uPwxn5Zu0u4hvhtEN3NOp7Rymi1/Pbz6w==	2026-05-25 09:10:08.829834-03	2026-05-18 09:11:16.417434-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-18 09:10:08.82982-03	2026-05-18 09:11:16.417437-03
7a0db4fa-89c0-4c6e-a61f-fa7716d25102	wlWbLGobQTe2cSKkg+1VnV2xLFwqWBp0ahwVfAOSK7oOI4JleCnr+oK/jIJb6ciO8dIuZ9Ak0O6TLQ0L1c6OWg==	2026-05-27 12:17:05.93607-03	2026-05-20 12:27:03.99975-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-20 12:17:05.935451-03	2026-05-20 12:27:03.999751-03
c0b3d9fd-644b-4eff-afc5-5b4c2c1bff8e	lkygQPIrLTUeDGDCgRD9451BW3VcGAH1ERLSH+TG78tecG596591dCNAlRo838NcIuo5d2AopO1StKT6bETWDg==	2026-05-25 09:11:19.246051-03	2026-05-20 12:27:03.998826-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-18 09:11:19.245998-03	2026-05-20 12:27:03.999572-03
3cc817f4-e0e2-45ba-ac2e-4b2d258e3fc4	eDQ8LkSRjkbCztSnLq1Xe3HQP++mOPhVlxtqDCu98BeMEkem4092G7g0oiWKOPzemUBhaQadId0OccXbRwNgPQ==	2026-05-27 12:27:07.493709-03	2026-05-20 13:42:06.68071-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-20 12:27:07.49364-03	2026-05-20 13:42:06.681494-03
44ff43f1-c6a1-4316-92aa-a728e787df0c	CD8edFOREYFAsNGZyJm5vHE1XZ8LewqMPk5D/pJQ+BSN+x0SE3XVlAuTHugnvaUWJMBLwkCJhKR1zV5eK50INA==	2026-05-27 13:41:19.591113-03	2026-05-20 13:42:06.681501-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-20 13:41:19.590751-03	2026-05-20 13:42:06.681502-03
56298a63-2f3d-4dbe-be00-1b2e4cf6e864	VCT/IfAbKIDl0qrQZW8x5gwReJmwV420jZhahikp/ldpbqCp1I+GR5S1vKxO0JKvhQrwA4AC8GtMby1yEj9XQg==	2026-05-28 12:08:41.831178-03	2026-05-21 12:09:00.397166-03	019e4b14-e59c-7339-9c93-ff604f1db6a9	2026-05-21 12:08:41.830842-03	2026-05-21 12:09:00.397456-03
058bca71-9c04-4131-9f31-8e14dee6c6dc	WdL06SdXfv+cW2YYHt6BDtfctupMyjTX+A+KZaoiSOveGYMXB71oXPkKPd30Q4PW29RjsNnqvSbe1ZaIykrHOQ==	2026-05-27 20:41:57.343678-03	2026-05-21 14:16:19.232981-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-20 20:41:57.343185-03	2026-05-21 14:16:19.233124-03
4aa322db-2c20-4b97-8659-3552eb8d686a	gZcc76mzo1YrtpffPE3uJL0Lt7hASjcBVaXlc8qgvDmmYqpyPvy0ZNxyVViza/U6jYNAxZgxrBn9CYyrPNa6Cw==	2026-05-28 14:12:01.445543-03	2026-05-21 14:16:19.233125-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-21 14:12:01.445165-03	2026-05-21 14:16:19.233125-03
e620b100-2cf7-4e6b-b47f-824f94c37816	sB+A/KpT7D+Y5Kj96PYEroCv+MfC1JdUqANTfycCA7Y0IaO3jw/oxAXrR1yyo+vDA+m0v2r//9gqOIyQtUI3lw==	2026-05-28 14:16:26.506092-03	2026-05-21 14:54:42.528047-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-21 14:16:26.506064-03	2026-05-21 14:54:42.528094-03
b1d3063e-2055-426f-8176-eae8af88a745	fDkwy21qS4mR5gxp28mgtmT7kKlGLewLqerYw5cVnHhbKiA8GbHAvN2R8n1XJUFqXl6whZMGSRmT2hTc0S5ClA==	2026-05-28 14:54:45.444594-03	2026-05-21 14:58:14.555505-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-21 14:54:45.444586-03	2026-05-21 14:58:14.555506-03
6af9294a-b3cc-4351-83a4-cd7460fc47b6	kM3L4H/YA3MAz3K95lBoZUE++xWZvQ5PnWpyS/kePDlfWdQjRaian2yHqvjNoqnvIC0LkXjVmxow99joh9jvwA==	2026-05-28 14:58:16.991278-03	2026-05-21 15:40:29.312606-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-21 14:58:16.991263-03	2026-05-21 15:40:29.312791-03
427fd80d-30d7-44df-b60a-1ac9298123fa	6d9cgpj+ofKh/OzHU/SI+48rAKsDKHO9LEcpXLQzEJrhX4eAGmv515ZXiahCncU48RfW5mOugzxHNtarHxFc3w==	2026-05-28 15:40:32.166758-03	2026-05-21 15:56:30.065437-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-21 15:40:32.166729-03	2026-05-21 15:56:30.065576-03
852819f9-9bc7-44b8-9ebc-9ae102244439	jA1mqzckvb3S17W0SZj6NlDkyNFZ2qOb+EDy/PWvm8rhGVwmZeZ2JAqo3FzVMYdHI84HlXXDJnvJCC783sMW8Q==	2026-05-28 15:56:37.366056-03	2026-05-21 15:57:00.713931-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-21 15:56:37.365904-03	2026-05-21 15:57:00.713932-03
9dc69d77-b976-4440-955b-dbb5b90b0fc9	QEelpqtW7zle6j/Pd2SRq6FxRxyJJCUfycHG88hAUoM6o3HMeuyUzbPV2bs+lydcLbiFoBmnax1etstXPGlGaA==	2026-05-28 15:57:10.913974-03	2026-05-21 15:57:14.717818-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-21 15:57:10.913929-03	2026-05-21 15:57:14.717819-03
bac47743-865e-4b27-a085-41f14941a88b	zjVjZiCaBQOf+FMI8L0owo/Y2x2Rap8Qjs9W3SRQC6rrL3I9MV0S57YMGZRyshCJnJsa0t3TEYMo5cQTLtKjVw==	2026-05-28 15:57:21.965859-03	2026-05-21 16:16:45.017351-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-21 15:57:21.965848-03	2026-05-21 16:16:45.017353-03
8b77252b-9799-459b-a90f-c7ca04b8f578	jAH27KF76egzT7x0U8QTMgCG8NpnMxuOQXxtXf74nOZOPYCcj6AxE1tI+xyyr+9YGd4Fay2xQStXsgkfKQfv9g==	2026-05-28 16:16:48.866606-03	2026-05-22 23:10:07.519534-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-21 16:16:48.866596-03	2026-05-22 23:10:07.519829-03
9fa7c20e-6543-4706-a12c-09ce4f627ad6	4eqrobvlWry8wAZxJyUs3m7ADkPtbKgefohgF9tN5kCFSCzuy788MtYCKr1yglBAnS+dejjh5/boB9VOs8nnfA==	2026-05-29 23:08:54.604471-03	2026-05-22 23:10:07.519943-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-22 23:08:54.604328-03	2026-05-22 23:10:07.519943-03
f6fe9baf-d4e5-4c87-84f1-14d1731dcf6f	1DFn1iW/AAu6x6HqRbiSWTxYFUxy71ISLs+zSlnPd8Rk3HekfsHMnhH/Z/wKJBbaKP1e0+40IYHCDDn1j8TdXw==	2026-05-28 17:24:37.285927-03	2026-05-22 23:10:07.519943-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-21 17:24:37.285916-03	2026-05-22 23:10:07.519943-03
6d3c14a4-11ca-4ee1-a95e-b2e99d8c2f45	Vk4qYpmJLKP78pC58F8WtJ2Kens2hrSZVPVkTeIWrXBAgZ/xcCe4ivW2lv7OgvTIQG+UQ+v2n8x7SuIUGwTzbA==	2026-05-29 23:10:11.427709-03	2026-05-22 23:12:09.647421-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-22 23:10:11.427653-03	2026-05-22 23:12:09.647423-03
9cdae33c-225f-4a00-b64a-c0eb6ee75af2	2f25IW3DDjboA2ocwiMvS4hvC263OW61OT2iMgiChSLGD/SGPeqTEs3qFhwzAOxZlePatqYlHSvdkhHHBDFmIw==	2026-05-29 23:16:03.142739-03	2026-05-22 23:23:05.082597-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-22 23:16:03.142733-03	2026-05-22 23:23:05.082597-03
dd2293a8-7618-437f-8082-76cc42c54646	VmTTMhZEjwCXAGo4psCmFai+1u/k6/pkN/mKgiylNbt9n2kQXssBiKstzART1bCY6PHNbsmLZCHqoPbBERojjA==	2026-05-29 23:12:14.8995-03	2026-05-22 23:23:05.082595-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-22 23:12:14.899493-03	2026-05-22 23:23:05.082596-03
5b098cc0-dc29-4785-962e-5083a8661d61	jxRsMNbKhjFn0qHgvUVG38T9EW9UG1NPm09sWr/Vb1fwaOx8wiS0VcdwCBuup5nK+tk9GP+O37Uckm5b+oc2nA==	2026-05-29 23:23:09.881831-03	2026-05-22 23:23:48.598209-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-22 23:23:09.881808-03	2026-05-22 23:23:48.598211-03
1eacabb5-a8f6-4737-bb2e-a8553526baab	zHWli+A+4BneIrDNQMxmQUYre0t7MgMwzm9QPnSQcGKOsxWjQxa4Tx0sGEqmQ6vWI1GegliNl2zIPAgkzjFP6w==	2026-05-29 23:23:51.656116-03	2026-05-22 23:23:57.89274-03	019e4b14-e59c-7339-9c93-ff604f1db6a9	2026-05-22 23:23:51.656102-03	2026-05-22 23:23:57.892743-03
1a2136de-8920-4797-b9c7-857168bb4376	E1SQh7YjvzQwydsgwfXhsBy8ru9zjp0Z+OmS1G7vRcyjTz6cT9NkGHHle+fcstphXOQnTVzIetAm4H682iZI1A==	2026-05-30 12:04:05.020255-03	2026-05-23 12:06:32.53908-03	019e4b14-e59c-7339-9c93-ff604f1db6a9	2026-05-23 12:04:05.020206-03	2026-05-23 12:06:32.53908-03
afef91be-86e3-4aeb-99f0-00d96ac39604	7lcDhKxLlWhZEnaiNP703yAbdf3zuwCiRtEy7UxSzYenQhtZpHhIJMk4dV03yonTD5VK0fXKBEBlre2HabG3tg==	2026-05-30 11:54:42.363913-03	2026-05-23 12:06:32.53866-03	019e4b14-e59c-7339-9c93-ff604f1db6a9	2026-05-23 11:54:42.36389-03	2026-05-23 12:06:32.538997-03
fcf5d6e7-fc62-411e-b1d1-f09ab7a81920	jt/iByLQSZUPy9VfKMPlMGKlHY6lZq/RmOp40RIWgMF2Kds1oXJfFCWVo6YSGq/8pZJvVBrp7qD68k5uua2WFg==	2026-05-30 12:03:57.852254-03	2026-05-23 12:06:32.539079-03	019e4b14-e59c-7339-9c93-ff604f1db6a9	2026-05-23 12:03:57.852128-03	2026-05-23 12:06:32.539079-03
53ace183-ccdf-4337-9aa8-00441cc9be80	u5/a4dOMKopIaJKtJlICiqSyTyWKxEaek7zJxWmNTNe1TutRlopw/fcBAKX+BqpOEU0uHLD3zlcm3bSDm8oNBA==	2026-05-30 11:54:16.136545-03	2026-05-23 12:08:38.367245-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-23 11:54:16.13642-03	2026-05-23 12:08:38.367248-03
a6f0098b-5bb8-40cc-a1fc-a0716320c321	YeHz/70GL39M+IFABwU7qicvTI6OvvUpUzNS4KnrWn3BHaz6GDUlq3ALRqDRScDnzYgwOIdyWRGop2xP4i/Cmw==	2026-05-30 11:54:28.667696-03	2026-05-23 12:08:38.367248-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-23 11:54:28.667667-03	2026-05-23 12:08:38.367248-03
8e8196cc-f8f1-4081-966d-8c94b781aca8	AcGVn3mlmEHcLduZkWH1DDiT96lhxNMdyHJnKtzus9LRQRmEWut5VSpaZdCKP+7SK+YOvLX9wno8GDbVSHodJg==	2026-05-29 23:24:03.474314-03	2026-05-23 12:59:44.503119-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-22 23:24:03.474309-03	2026-05-23 12:59:44.50312-03
3c18a277-5944-4ab9-87df-8f64636d3133	l9EZXEyFpfDQE7rW5TnDgNQYr1/u3TQwBAXGyiQwB4K5yNGbQgeZMNsAshWMweU9RPF2h4WR7Lr21Gd5E5FyIQ==	2026-05-30 12:04:11.411696-03	2026-05-23 12:06:32.53908-03	019e4b14-e59c-7339-9c93-ff604f1db6a9	2026-05-23 12:04:11.411689-03	2026-05-23 12:06:32.53908-03
eef97a44-dc8a-4806-9160-1b68b430bc83	kR8aUrVk3x9rBnPuEECR6IsQhg7wKYC3b49RcI4k5Z6sIXXmYyxsmdKfnXOtgrqs2hH5f/VcWhh5/s3XzMZGXQ==	2026-05-30 12:08:27.793922-03	\N	019e4b14-e59c-7339-9c93-ff604f1db6a9	2026-05-23 12:08:27.793911-03	\N
414cf890-04c2-46c0-9440-71d1b65aa84e	jcBjcl/KmT7miCgZhBJ3AT4o9PBM+BBtFcHrF+QK3M06TR6idxw5zPMrM5KkYa+M9jonRYCp1OP9K+Eb1KxMIQ==	2026-05-30 12:08:44.634249-03	2026-05-23 12:59:44.50312-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-23 12:08:44.634242-03	2026-05-23 12:59:44.50312-03
acd2a1a2-dc23-442b-a6dc-5cedacd77ceb	gE+zfo2uAR5Ie9JWD2q0mnkx4GBVyYCrGjY/TJE7k1/HRXG0ACaXxi5Po5t7BAgRvkmlFXDrnYr9BAQFv+07qg==	2026-05-30 12:05:27.943358-03	2026-05-23 12:06:32.53908-03	019e4b14-e59c-7339-9c93-ff604f1db6a9	2026-05-23 12:05:27.943349-03	2026-05-23 12:06:32.53908-03
aaeedf99-6907-40c5-be7a-366fcd8fdb20	HqMyMAnVIAncOsXfTAM4epgaUbydQGUOx3Ld3LJ05HSQIh+Jce3j4EIqT2nRByLhbjAzR1SIKuX6ACcy+Sbyxw==	2026-05-30 12:08:34.25058-03	2026-05-23 12:08:38.367249-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-23 12:08:34.25057-03	2026-05-23 12:08:38.367249-03
95d76624-498f-46c5-aaa3-ffbf581782bc	rX77hfdi+LfCoaGi/JwUENWz441JdpAAxT59chB8/r35OON8xa0pPh7gM+7Q2F98BI+NgpZOPojXOwn1TiaNVg==	2026-05-30 13:08:23.888758-03	2026-05-23 13:34:20.704079-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-23 13:08:23.888752-03	2026-05-23 13:34:20.704117-03
605a3860-125e-41f7-98f6-7536a4776d87	F16vBp++HKSsoou/GY6ndtZXSxWXurtiFnBLk2ZdNy6Ei1OAbAOMWMIqXU9JhIDS4AOWPaD8AvM8L6ovx6kfXg==	2026-05-30 13:34:22.770203-03	2026-05-23 13:34:31.768094-03	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-23 13:34:22.770195-03	2026-05-23 13:34:31.768096-03
4098c873-0297-49ab-b803-b8b29a980bc0	4ff7f7a4d5d76bb1a7223ec5e9db0a646a5912bd2fce0a7d02a95ec68e16d6c7	2026-05-30 20:03:53.06401-03	2026-05-23 20:13:28.296569-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-23 20:03:53.063429-03	2026-05-23 20:13:28.29657-03
7fad227b-8c3c-4ef2-80e7-c9345d04df4c	L2ffyGAeiehMpWqSw7RAq0Pfjyw3stlO8YwShYyXGgNxodZNlx+Jqmx8Zk+8dS/x9CwtLih2c1cuvfq+XFq2qA==	2026-05-30 13:34:35.287042-03	2026-05-23 20:13:28.296046-03	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-23 13:34:35.287034-03	2026-05-23 20:13:28.296388-03
a3785fc8-81fa-40a3-a3a2-63cd9de024f0	9270796af1ac9d3dc4d6eed3d4579549cc2cc984eea4da9117deb905f4c1e46f	2026-05-30 20:14:22.526039-03	\N	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-23 20:14:22.525911-03	\N
2e98ea76-a39c-46d4-84df-c55f6c72e0be	56f6e08b05148cdb0d260b7c22cfd24282b7cff17fa35542dc8e28431458e033	2026-05-30 20:46:13.871305-03	\N	019e2b98-51b2-7573-91f4-aa5fd96dd5d3	2026-05-23 20:46:13.871279-03	\N
518bc494-e674-41d5-94b7-c10e291b306f	2a5f84e2e43fd754980ae96c604f04309c0d4a640c100aa568f4a0f13025f4c6	2026-05-31 23:45:39.941705-03	\N	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-24 23:45:39.941316-03	\N
4e9b3388-1caf-464b-bb1c-ba146bb8c9f0	37885a8184c32bdd0e959edd9534ce1a0ef3e77ca2c5249dbf9ce0e68edad8a7	2026-06-01 00:40:02.311142-03	\N	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-25 00:40:02.310744-03	\N
c9d7110c-65dd-4e7d-a51f-c9abeba3c9d1	3854cd24cf88a9fce1978ff1b3600e127ea6df00776104379e366569cc92b144	2026-06-01 08:51:11.311455-03	\N	019e27a2-023c-7bd4-b72b-9408ae963ebd	2026-05-25 08:51:11.311078-03	\N
\.


--
-- Data for Name: role_claims; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_claims ("Id", "RoleId", "ClaimType", "ClaimValue") FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles ("Id", "Name", "NormalizedName", "ConcurrencyStamp") FROM stdin;
019e27a2-011c-766f-8efe-39560ad0e7db	Admin	ADMIN	\N
019e27a2-018f-78c9-af5c-a18c8ad2e430	Customer	CUSTOMER	\N
\.


--
-- Data for Name: user_claims; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_claims ("Id", "UserId", "ClaimType", "ClaimValue") FROM stdin;
\.


--
-- Data for Name: user_logins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_logins ("LoginProvider", "ProviderKey", "ProviderDisplayName", "UserId") FROM stdin;
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles ("UserId", "RoleId") FROM stdin;
019e27a2-023c-7bd4-b72b-9408ae963ebd	019e27a2-011c-766f-8efe-39560ad0e7db
019e2b98-51b2-7573-91f4-aa5fd96dd5d3	019e27a2-018f-78c9-af5c-a18c8ad2e430
019e3644-d678-723c-9007-bcc56383c267	019e27a2-018f-78c9-af5c-a18c8ad2e430
019e4b14-e59c-7339-9c93-ff604f1db6a9	019e27a2-018f-78c9-af5c-a18c8ad2e430
\.


--
-- Data for Name: user_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_tokens ("UserId", "LoginProvider", "Name", "Value") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users ("Id", "FullName", "CreatedAt", "IsActive", "UserName", "NormalizedUserName", "Email", "NormalizedEmail", "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp", "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", "LockoutEnd", "LockoutEnabled", "AccessFailedCount") FROM stdin;
019e27a2-023c-7bd4-b72b-9408ae963ebd	Administrator	2026-05-14 14:56:29.223642-03	t	bozyk_@hotmail.com	BOZYK_@HOTMAIL.COM	bozyk_@hotmail.com	BOZYK_@HOTMAIL.COM	t	AQAAAAIAAYagAAAAEOeBBb4//sPRWrhvnX8mJnBX2yVufOphw86p6OXHuDjAVqR50HEjDVAa6Z/xeKcYaw==	ER7K5N264MW2SOWOBYYFJMVIQ2MKSGMJ	d05ddc29-4d2e-43aa-96a7-215e7cf5fb7b	\N	f	f	\N	t	0
019e2b98-51b2-7573-91f4-aa5fd96dd5d3	Lucas	2026-05-15 09:24:22.968745-03	t	capoani_@hotmail.com	CAPOANI_@HOTMAIL.COM	capoani_@hotmail.com	CAPOANI_@HOTMAIL.COM	t	AQAAAAIAAYagAAAAEPATimNhAjQglbDLnDuk6N1pbud56S9iGlj3bRACNPcChUzQF7/FR+NrVcHDrIYj8g==	2GJW456VP4YA5WEJ2AVAW5LJBYGE4XJD	ade365eb-9f69-439b-916e-c3fdf8324ad3	\N	f	f	\N	t	0
019e3644-d678-723c-9007-bcc56383c267	lucas	2026-05-17 11:09:01.387248-03	t	lucas_@hotmail.com	LUCAS_@HOTMAIL.COM	lucas_@hotmail.com	LUCAS_@HOTMAIL.COM	t	AQAAAAIAAYagAAAAEIOvB61Areyo3xj5Ryzt5soi5utgZsU3YLGaX1b9N1ZjT6YYNg9zqF0YdSvB9e+FfQ==	EWVSBZHKR3Z33U2ZP2LZZTMRMCPE6IP5	bccc96d6-624e-4bd5-bc55-8c5b030ee8ca	\N	f	f	\N	t	0
019e4b14-e59c-7339-9c93-ff604f1db6a9	Usuario	2026-05-21 12:08:41.053599-03	t	bozyk.lucas@outlook.com	BOZYK.LUCAS@OUTLOOK.COM	bozyk.lucas@outlook.com	BOZYK.LUCAS@OUTLOOK.COM	t	AQAAAAIAAYagAAAAEIJOmLyguCHN9WDW2t+lSns/lsuKrETlLiVVKNzYSpeK/wdHXDtK+zlzBEasHS0AUQ==	CDOGKXU7ODTSZPCTFN37ENEUSTYHYCKJ	6c85ccbe-4168-43a7-8455-75181e97217f	\N	f	f	\N	t	0
\.


--
-- Name: role_claims_Id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."role_claims_Id_seq"', 1, false);


--
-- Name: user_claims_Id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."user_claims_Id_seq"', 1, false);


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: brands PK_brands; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT "PK_brands" PRIMARY KEY ("Id");


--
-- Name: categories PK_categories; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT "PK_categories" PRIMARY KEY ("Id");


--
-- Name: licenses PK_licenses; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT "PK_licenses" PRIMARY KEY ("Id");


--
-- Name: orders PK_orders; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "PK_orders" PRIMARY KEY ("Id");


--
-- Name: outbox_messages PK_outbox_messages; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outbox_messages
    ADD CONSTRAINT "PK_outbox_messages" PRIMARY KEY ("Id");


--
-- Name: payments PK_payments; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT "PK_payments" PRIMARY KEY ("Id");


--
-- Name: product_images PK_product_images; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT "PK_product_images" PRIMARY KEY ("Id");


--
-- Name: products PK_products; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "PK_products" PRIMARY KEY ("Id");


--
-- Name: refresh_tokens PK_refresh_tokens; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "PK_refresh_tokens" PRIMARY KEY ("Id");


--
-- Name: role_claims PK_role_claims; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_claims
    ADD CONSTRAINT "PK_role_claims" PRIMARY KEY ("Id");


--
-- Name: roles PK_roles; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT "PK_roles" PRIMARY KEY ("Id");


--
-- Name: user_claims PK_user_claims; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_claims
    ADD CONSTRAINT "PK_user_claims" PRIMARY KEY ("Id");


--
-- Name: user_logins PK_user_logins; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_logins
    ADD CONSTRAINT "PK_user_logins" PRIMARY KEY ("LoginProvider", "ProviderKey");


--
-- Name: user_roles PK_user_roles; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT "PK_user_roles" PRIMARY KEY ("UserId", "RoleId");


--
-- Name: user_tokens PK_user_tokens; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT "PK_user_tokens" PRIMARY KEY ("UserId", "LoginProvider", "Name");


--
-- Name: users PK_users; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_users" PRIMARY KEY ("Id");


--
-- Name: EmailIndex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "EmailIndex" ON public.users USING btree ("NormalizedEmail");


--
-- Name: IX_brands_Slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_brands_Slug" ON public.brands USING btree ("Slug");


--
-- Name: IX_categories_Slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_categories_Slug" ON public.categories USING btree ("Slug");


--
-- Name: IX_licenses_OrderId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_licenses_OrderId" ON public.licenses USING btree ("OrderId");


--
-- Name: IX_licenses_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_licenses_ProductId" ON public.licenses USING btree ("ProductId");


--
-- Name: IX_licenses_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_licenses_UserId" ON public.licenses USING btree ("UserId");


--
-- Name: IX_orders_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_orders_ProductId" ON public.orders USING btree ("ProductId");


--
-- Name: IX_orders_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_orders_UserId" ON public.orders USING btree ("UserId");


--
-- Name: IX_outbox_messages_OccurredAt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_outbox_messages_OccurredAt" ON public.outbox_messages USING btree ("OccurredAt");


--
-- Name: IX_outbox_messages_ProcessedAt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_outbox_messages_ProcessedAt" ON public.outbox_messages USING btree ("ProcessedAt");


--
-- Name: IX_payments_OrderId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_payments_OrderId" ON public.payments USING btree ("OrderId");


--
-- Name: IX_product_images_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_product_images_ProductId" ON public.product_images USING btree ("ProductId");


--
-- Name: IX_product_images_ProductId_SortOrder; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_product_images_ProductId_SortOrder" ON public.product_images USING btree ("ProductId", "SortOrder");


--
-- Name: IX_products_BrandId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_products_BrandId" ON public.products USING btree ("BrandId");


--
-- Name: IX_products_CategoryId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_products_CategoryId" ON public.products USING btree ("CategoryId");


--
-- Name: IX_products_PrimaryImageId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_products_PrimaryImageId" ON public.products USING btree ("PrimaryImageId");


--
-- Name: IX_products_Slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_products_Slug" ON public.products USING btree ("Slug");


--
-- Name: IX_refresh_tokens_Token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_refresh_tokens_Token" ON public.refresh_tokens USING btree ("Token");


--
-- Name: IX_refresh_tokens_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_refresh_tokens_UserId" ON public.refresh_tokens USING btree ("UserId");


--
-- Name: IX_role_claims_RoleId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_role_claims_RoleId" ON public.role_claims USING btree ("RoleId");


--
-- Name: IX_user_claims_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_claims_UserId" ON public.user_claims USING btree ("UserId");


--
-- Name: IX_user_logins_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_logins_UserId" ON public.user_logins USING btree ("UserId");


--
-- Name: IX_user_roles_RoleId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_roles_RoleId" ON public.user_roles USING btree ("RoleId");


--
-- Name: RoleNameIndex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "RoleNameIndex" ON public.roles USING btree ("NormalizedName");


--
-- Name: UserNameIndex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "UserNameIndex" ON public.users USING btree ("NormalizedUserName");


--
-- Name: licenses FK_licenses_orders_OrderId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT "FK_licenses_orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES public.orders("Id") ON DELETE SET NULL;


--
-- Name: licenses FK_licenses_products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT "FK_licenses_products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public.products("Id") ON DELETE RESTRICT;


--
-- Name: licenses FK_licenses_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT "FK_licenses_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE SET NULL;


--
-- Name: orders FK_orders_products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "FK_orders_products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public.products("Id") ON DELETE RESTRICT;


--
-- Name: orders FK_orders_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "FK_orders_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE RESTRICT;


--
-- Name: payments FK_payments_orders_OrderId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT "FK_payments_orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES public.orders("Id") ON DELETE CASCADE;


--
-- Name: product_images FK_product_images_products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT "FK_product_images_products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public.products("Id") ON DELETE CASCADE;


--
-- Name: products FK_products_brands_BrandId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "FK_products_brands_BrandId" FOREIGN KEY ("BrandId") REFERENCES public.brands("Id") ON DELETE SET NULL;


--
-- Name: products FK_products_categories_CategoryId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "FK_products_categories_CategoryId" FOREIGN KEY ("CategoryId") REFERENCES public.categories("Id") ON DELETE SET NULL;


--
-- Name: products FK_products_product_images_PrimaryImageId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "FK_products_product_images_PrimaryImageId" FOREIGN KEY ("PrimaryImageId") REFERENCES public.product_images("Id") ON DELETE SET NULL;


--
-- Name: refresh_tokens FK_refresh_tokens_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "FK_refresh_tokens_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE CASCADE;


--
-- Name: role_claims FK_role_claims_roles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_claims
    ADD CONSTRAINT "FK_role_claims_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public.roles("Id") ON DELETE CASCADE;


--
-- Name: user_claims FK_user_claims_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_claims
    ADD CONSTRAINT "FK_user_claims_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE CASCADE;


--
-- Name: user_logins FK_user_logins_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_logins
    ADD CONSTRAINT "FK_user_logins_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE CASCADE;


--
-- Name: user_roles FK_user_roles_roles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT "FK_user_roles_roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public.roles("Id") ON DELETE CASCADE;


--
-- Name: user_roles FK_user_roles_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT "FK_user_roles_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE CASCADE;


--
-- Name: user_tokens FK_user_tokens_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT "FK_user_tokens_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users("Id") ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 1bErzYHd0OuGErDgaB6HwaINWdnplNRk8gdIjUtf03wnhjJyCuTy2jKZjiaDFL1

--
-- Database "idelivery_delivery" dump
--

--
-- PostgreSQL database dump
--

\restrict 9ME10hQZKrcwXjnhXOdGI13PEqd4alQGnWp1Ex7mEvbG6wvl83Cc0gLu37WO2IN

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: idelivery_delivery; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE idelivery_delivery WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Portuguese_Brazil.1252';


ALTER DATABASE idelivery_delivery OWNER TO postgres;

\unrestrict 9ME10hQZKrcwXjnhXOdGI13PEqd4alQGnWp1Ex7mEvbG6wvl83Cc0gLu37WO2IN
\connect idelivery_delivery
\restrict 9ME10hQZKrcwXjnhXOdGI13PEqd4alQGnWp1Ex7mEvbG6wvl83Cc0gLu37WO2IN

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: CartItems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CartItems" (
    "Id" uuid NOT NULL,
    "CartId" uuid NOT NULL,
    "ProductId" uuid NOT NULL,
    "Quantity" integer NOT NULL,
    "Comment" text
);


ALTER TABLE public."CartItems" OWNER TO postgres;

--
-- Name: Carts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Carts" (
    "Id" uuid NOT NULL,
    "CustomerId" uuid NOT NULL,
    "IsActive" boolean NOT NULL,
    "RestaurantId" uuid
);


ALTER TABLE public."Carts" OWNER TO postgres;

--
-- Name: Coupons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Coupons" (
    "Id" uuid NOT NULL,
    "Code" text NOT NULL,
    "DiscountType" integer NOT NULL,
    "Value" numeric NOT NULL,
    "MinValue" numeric NOT NULL,
    "ExpirationDate" timestamp with time zone NOT NULL,
    "UsageLimit" integer NOT NULL,
    "UsedCount" integer NOT NULL
);


ALTER TABLE public."Coupons" OWNER TO postgres;

--
-- Name: CustomerAddresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CustomerAddresses" (
    "Id" uuid NOT NULL,
    "CustomerId" uuid NOT NULL,
    "Street" text NOT NULL,
    "Number" text NOT NULL,
    "Complement" text,
    "Neighborhood" text NOT NULL,
    "City" text NOT NULL,
    "State" text NOT NULL,
    "ZipCode" text NOT NULL,
    "IsDefault" boolean NOT NULL
);


ALTER TABLE public."CustomerAddresses" OWNER TO postgres;

--
-- Name: Customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Customers" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "FullName" text NOT NULL,
    "Phone" text NOT NULL,
    "Cpf" text,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."Customers" OWNER TO postgres;

--
-- Name: Deliveries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Deliveries" (
    "Id" uuid NOT NULL,
    "OrderId" uuid NOT NULL,
    "DeliveryDriverId" uuid,
    "Status" integer NOT NULL,
    "AddressSnapshot" text NOT NULL,
    "EstimatedDeliveryTime" timestamp with time zone NOT NULL,
    "DeliveredAt" timestamp with time zone,
    "CreatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."Deliveries" OWNER TO postgres;

--
-- Name: DeliveryDrivers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DeliveryDrivers" (
    "Id" uuid NOT NULL,
    "Name" text NOT NULL
);


ALTER TABLE public."DeliveryDrivers" OWNER TO postgres;

--
-- Name: MenuCategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."MenuCategories" (
    "Id" uuid NOT NULL,
    "Name" text NOT NULL
);


ALTER TABLE public."MenuCategories" OWNER TO postgres;

--
-- Name: OrderItems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OrderItems" (
    "Id" uuid NOT NULL,
    "OrderId" uuid NOT NULL,
    "ProductId" uuid NOT NULL,
    "ProductName" text NOT NULL,
    "UnitPrice" numeric NOT NULL,
    "Quantity" integer NOT NULL,
    "TotalPrice" numeric NOT NULL,
    "Observation" text
);


ALTER TABLE public."OrderItems" OWNER TO postgres;

--
-- Name: Orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Orders" (
    "Id" uuid NOT NULL,
    "CustomerId" uuid NOT NULL,
    "RestaurantId" uuid NOT NULL,
    "Status" integer NOT NULL,
    "Subtotal" numeric NOT NULL,
    "DeliveryFee" numeric NOT NULL,
    "Discount" numeric NOT NULL,
    "Total" numeric NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "ConfirmedAt" timestamp with time zone,
    "CancelledAt" timestamp with time zone,
    "CompletedAt" timestamp with time zone
);


ALTER TABLE public."Orders" OWNER TO postgres;

--
-- Name: Payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Payments" (
    "Id" uuid NOT NULL,
    "OrderId" uuid NOT NULL,
    "Method" integer NOT NULL,
    "Status" integer NOT NULL,
    "Amount" numeric NOT NULL,
    "Gateway" text NOT NULL,
    "ExternalTransactionId" text NOT NULL,
    "PaidAt" timestamp with time zone,
    "CreatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."Payments" OWNER TO postgres;

--
-- Name: ProductOptionGroups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProductOptionGroups" (
    "Id" uuid NOT NULL,
    "ProductId" uuid NOT NULL,
    "Name" text NOT NULL,
    "MinSelection" integer NOT NULL,
    "MaxSelection" integer NOT NULL
);


ALTER TABLE public."ProductOptionGroups" OWNER TO postgres;

--
-- Name: ProductOptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProductOptions" (
    "Id" uuid NOT NULL,
    "ProductOptionGroupId" uuid NOT NULL,
    "Name" text NOT NULL,
    "AdditionalPrice" numeric NOT NULL
);


ALTER TABLE public."ProductOptions" OWNER TO postgres;

--
-- Name: Products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Products" (
    "Id" uuid NOT NULL,
    "RestaurantId" uuid NOT NULL,
    "MenuCategoryId" uuid NOT NULL,
    "Name" text NOT NULL,
    "Description" text NOT NULL,
    "Price" numeric NOT NULL,
    "PromotionalPrice" numeric,
    "IsAvailable" boolean NOT NULL,
    "ImageUrl" text,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."Products" OWNER TO postgres;

--
-- Name: RestaurantCategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RestaurantCategories" (
    "Id" uuid NOT NULL,
    "Name" text NOT NULL
);


ALTER TABLE public."RestaurantCategories" OWNER TO postgres;

--
-- Name: Restaurants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Restaurants" (
    "Id" uuid NOT NULL,
    "Name" text NOT NULL,
    "Description" text NOT NULL,
    "Cnpj" text NOT NULL,
    "Phone" text NOT NULL,
    "Email" text NOT NULL,
    "IsOpen" boolean NOT NULL,
    "CategoryId" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    "ProfileImageUrl" text
);


ALTER TABLE public."Restaurants" OWNER TO postgres;

--
-- Name: Reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Reviews" (
    "Id" uuid NOT NULL,
    "CustomerId" uuid NOT NULL,
    "RestaurantId" uuid NOT NULL,
    "OrderId" uuid NOT NULL,
    "Rating" integer NOT NULL,
    "Comment" text NOT NULL
);


ALTER TABLE public."Reviews" OWNER TO postgres;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- Data for Name: CartItems; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CartItems" ("Id", "CartId", "ProductId", "Quantity", "Comment") FROM stdin;
25bc995c-41f7-4f93-bc4b-8421a1efa874	dc8a5ca0-92cf-40d2-a7eb-dc5178052221	1a757d63-2c0b-400e-bd50-1c16c5cf0581	2	\N
5dad3dc7-97a9-449f-8d4a-f8122df68fc5	dc8a5ca0-92cf-40d2-a7eb-dc5178052221	204af529-6cb0-41e8-ba9c-2f18c9260c0a	1	\N
87a587ed-a3e1-4142-96b4-eae648fd1022	c36e66a0-427f-40f7-bb05-c11167584853	1a757d63-2c0b-400e-bd50-1c16c5cf0581	1	\N
5cc64487-fe00-42ce-a7b4-20e30b5b7653	1950250f-ebe4-4f74-ad6e-6c5a68d16182	01c60e5c-78e5-43c8-8d25-5f1a854ade68	1	\N
29c0d96f-22c4-4eda-b043-f00a16b5747c	a087abff-fc9c-4daf-9406-616fb9baef9f	842d9fd0-ead5-4ae0-aee4-28687d0305c8	3	\N
4e89af21-f819-426d-af12-e60df4b5e652	db9f82bc-0f0f-4ec2-aa16-6775e15a3aa3	1a757d63-2c0b-400e-bd50-1c16c5cf0581	1	\N
03b3f3ef-472e-440d-91cb-0560fca879a1	db9f82bc-0f0f-4ec2-aa16-6775e15a3aa3	204af529-6cb0-41e8-ba9c-2f18c9260c0a	1	\N
\.


--
-- Data for Name: Carts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Carts" ("Id", "CustomerId", "IsActive", "RestaurantId") FROM stdin;
dc8a5ca0-92cf-40d2-a7eb-dc5178052221	8fdf6000-1587-4c77-93a0-3feb07b25b99	f	fb08e19f-18eb-4c75-ade5-9030cc9d6834
c36e66a0-427f-40f7-bb05-c11167584853	8fdf6000-1587-4c77-93a0-3feb07b25b99	f	fb08e19f-18eb-4c75-ade5-9030cc9d6834
1950250f-ebe4-4f74-ad6e-6c5a68d16182	8fdf6000-1587-4c77-93a0-3feb07b25b99	f	f758744f-983e-4d2f-8a73-c46734360258
a087abff-fc9c-4daf-9406-616fb9baef9f	8fdf6000-1587-4c77-93a0-3feb07b25b99	f	f758744f-983e-4d2f-8a73-c46734360258
db9f82bc-0f0f-4ec2-aa16-6775e15a3aa3	8fdf6000-1587-4c77-93a0-3feb07b25b99	f	fb08e19f-18eb-4c75-ade5-9030cc9d6834
\.


--
-- Data for Name: Coupons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Coupons" ("Id", "Code", "DiscountType", "Value", "MinValue", "ExpirationDate", "UsageLimit", "UsedCount") FROM stdin;
\.


--
-- Data for Name: CustomerAddresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CustomerAddresses" ("Id", "CustomerId", "Street", "Number", "Complement", "Neighborhood", "City", "State", "ZipCode", "IsDefault") FROM stdin;
4b5001fe-5256-40cf-90fc-dde0c5e51fc6	8fdf6000-1587-4c77-93a0-3feb07b25b99	rua joao	121	nada	aero	marilia	SP	17514478	t
\.


--
-- Data for Name: Customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Customers" ("Id", "UserId", "FullName", "Phone", "Cpf", "CreatedAt", "UpdatedAt") FROM stdin;
e75ba7c0-4ea0-4b75-b300-ca3a85a0a7d3	e7447bf7-7c90-4162-b395-6a3f2695c455	customer	11999999999	\N	2026-06-01 14:34:30.464764-03	2026-06-01 14:34:30.464768-03
8fdf6000-1587-4c77-93a0-3feb07b25b99	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	cliente	11999999999	\N	2026-06-01 14:52:37.032581-03	2026-06-01 14:52:37.032581-03
\.


--
-- Data for Name: Deliveries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Deliveries" ("Id", "OrderId", "DeliveryDriverId", "Status", "AddressSnapshot", "EstimatedDeliveryTime", "DeliveredAt", "CreatedAt") FROM stdin;
ea554382-7ed9-48d4-8eef-08d06fceb660	eb76395e-991b-4567-b0f3-a8cfd9ef8708	9f0fc25e-1f8f-42ad-a714-90cc43699ee5	3	rua joao, 121 - aero, marilia/SP - 17514478	2026-06-02 17:49:48.372984-03	2026-06-02 17:15:27.309594-03	2026-06-02 17:04:48.372811-03
c9ccd5db-3c96-4e1d-a882-d98d836fd955	5ce8f71d-e98d-4097-9b32-d17b0be1565a	9f0fc25e-1f8f-42ad-a714-90cc43699ee5	1	rua joao, 121 - aero, marilia/SP - 17514478	2026-06-02 18:09:54.438889-03	\N	2026-06-02 17:24:54.438709-03
6a1c26fc-ec02-41ee-a98f-3e94cff761a5	5b3a9f9d-3f87-48f8-8dad-4a10ac239e19	9f0fc25e-1f8f-42ad-a714-90cc43699ee5	3	rua joao, 121 - aero, marilia/SP - 17514478	2026-06-02 18:57:13.011406-03	2026-06-02 18:12:39.221485-03	2026-06-02 18:12:13.011061-03
\.


--
-- Data for Name: DeliveryDrivers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DeliveryDrivers" ("Id", "Name") FROM stdin;
9f0fc25e-1f8f-42ad-a714-90cc43699ee5	driver@idelivery.local
\.


--
-- Data for Name: MenuCategories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."MenuCategories" ("Id", "Name") FROM stdin;
11111111-1111-1111-1111-111111111111	Japonesa
22222222-2222-2222-2222-222222222222	Lanches
33333333-3333-3333-3333-333333333333	Pizza
44444444-4444-4444-4444-444444444444	Brasileira
55555555-5555-5555-5555-555555555555	Saudavel
66666666-6666-6666-6666-666666666666	Sobremesa
77777777-7777-7777-7777-777777777777	Italiana
88888888-8888-8888-8888-888888888888	Mexicana
99999999-9999-9999-9999-999999999999	Arabe
aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Chinesa
bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	Indiana
cccccccc-cccc-cccc-cccc-cccccccccccc	Massas
dddddddd-dddd-dddd-dddd-dddddddddddd	Frutos do Mar
eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee	Vegetariana
ffffffff-ffff-ffff-ffff-ffffffffffff	Acaí e Sucos
\.


--
-- Data for Name: OrderItems; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."OrderItems" ("Id", "OrderId", "ProductId", "ProductName", "UnitPrice", "Quantity", "TotalPrice", "Observation") FROM stdin;
2fa6ba51-ca16-4906-af23-22cff6bbef76	f7fa7004-226e-4459-87c8-186d4c05729e	1a757d63-2c0b-400e-bd50-1c16c5cf0581	Chicken Crispy Burger	32.90	2	65.80	\N
9ec4f65d-e038-4493-8b8f-22b17df939a9	f7fa7004-226e-4459-87c8-186d4c05729e	204af529-6cb0-41e8-ba9c-2f18c9260c0a	Onion Rings	19.90	1	19.90	\N
6c3f8f48-b474-450c-9dd5-bfc62d58be6a	cba1fcd7-8881-46da-bb14-ee70e248c26e	1a757d63-2c0b-400e-bd50-1c16c5cf0581	Chicken Crispy Burger	32.90	1	32.90	\N
95ac73c7-e001-4e0d-ab8e-af43cb1fcc49	eb76395e-991b-4567-b0f3-a8cfd9ef8708	01c60e5c-78e5-43c8-8d25-5f1a854ade68	Gelato Morango	15.90	1	15.90	\N
0f2f0dd5-ddfb-494f-b385-1be4c8df81d2	5ce8f71d-e98d-4097-9b32-d17b0be1565a	842d9fd0-ead5-4ae0-aee4-28687d0305c8	Gelato Chocolate Belga	16.90	3	50.70	\N
89a1eaf2-8ac6-454c-915d-16ecd8af0cc7	5b3a9f9d-3f87-48f8-8dad-4a10ac239e19	1a757d63-2c0b-400e-bd50-1c16c5cf0581	Chicken Crispy Burger	32.90	1	32.90	\N
c46f8c26-3077-4bd5-8bdb-a64e54136316	5b3a9f9d-3f87-48f8-8dad-4a10ac239e19	204af529-6cb0-41e8-ba9c-2f18c9260c0a	Onion Rings	19.90	1	19.90	\N
\.


--
-- Data for Name: Orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Orders" ("Id", "CustomerId", "RestaurantId", "Status", "Subtotal", "DeliveryFee", "Discount", "Total", "CreatedAt", "ConfirmedAt", "CancelledAt", "CompletedAt") FROM stdin;
f7fa7004-226e-4459-87c8-186d4c05729e	8fdf6000-1587-4c77-93a0-3feb07b25b99	fb08e19f-18eb-4c75-ade5-9030cc9d6834	0	85.70	0	0	85.70	2026-06-02 16:27:59.992939-03	\N	\N	\N
cba1fcd7-8881-46da-bb14-ee70e248c26e	8fdf6000-1587-4c77-93a0-3feb07b25b99	fb08e19f-18eb-4c75-ade5-9030cc9d6834	0	32.90	8	0	40.90	2026-06-02 16:30:26.094163-03	\N	\N	\N
eb76395e-991b-4567-b0f3-a8cfd9ef8708	8fdf6000-1587-4c77-93a0-3feb07b25b99	f758744f-983e-4d2f-8a73-c46734360258	4	15.90	8	0	23.90	2026-06-02 17:04:48.347241-03	\N	\N	2026-06-02 17:15:27.326679-03
5ce8f71d-e98d-4097-9b32-d17b0be1565a	8fdf6000-1587-4c77-93a0-3feb07b25b99	f758744f-983e-4d2f-8a73-c46734360258	0	50.70	8	0	58.70	2026-06-02 17:24:54.422788-03	\N	\N	\N
5b3a9f9d-3f87-48f8-8dad-4a10ac239e19	8fdf6000-1587-4c77-93a0-3feb07b25b99	fb08e19f-18eb-4c75-ade5-9030cc9d6834	4	52.80	8	0	60.80	2026-06-02 18:12:12.920032-03	\N	\N	2026-06-02 18:12:39.243826-03
\.


--
-- Data for Name: Payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Payments" ("Id", "OrderId", "Method", "Status", "Amount", "Gateway", "ExternalTransactionId", "PaidAt", "CreatedAt") FROM stdin;
\.


--
-- Data for Name: ProductOptionGroups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ProductOptionGroups" ("Id", "ProductId", "Name", "MinSelection", "MaxSelection") FROM stdin;
\.


--
-- Data for Name: ProductOptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ProductOptions" ("Id", "ProductOptionGroupId", "Name", "AdditionalPrice") FROM stdin;
\.


--
-- Data for Name: Products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Products" ("Id", "RestaurantId", "MenuCategoryId", "Name", "Description", "Price", "PromotionalPrice", "IsAvailable", "ImageUrl", "CreatedAt", "UpdatedAt") FROM stdin;
01c60e5c-78e5-43c8-8d25-5f1a854ade68	f758744f-983e-4d2f-8a73-c46734360258	66666666-6666-6666-6666-666666666666	Gelato Morango	Gelato de morango com pedaços da fruta	15.9	\N	t	/uploads/products/Gelato_morango.png	2026-06-01 16:50:19.38563-03	2026-06-05 13:21:41.762068-03
210a2a22-b750-4ed1-bc4b-f8a21029add7	f758744f-983e-4d2f-8a73-c46734360258	66666666-6666-6666-6666-666666666666	Gelato Pistache	Gelato artesanal de pistache	17.9	\N	t	/uploads/products/gelato_pistache.png	2026-06-01 16:50:19.383087-03	2026-06-05 13:22:32.003695-03
2a26950a-22e5-41d6-954f-0dd1779b726e	f758744f-983e-4d2f-8a73-c46734360258	66666666-6666-6666-6666-666666666666	Affogato	Espresso com gelato de baunilha	22.9	\N	t	/uploads/products/Affogato.png	2026-06-01 16:50:19.389276-03	2026-06-05 13:23:33.974865-03
4f0438c7-c1cf-45c9-ae6f-44eddd3a8379	f758744f-983e-4d2f-8a73-c46734360258	66666666-6666-6666-6666-666666666666	Copo 2 Sabores	Copo médio com dois sabores	18.9	16.9	t	/uploads/products/copo_2sabores.png	2026-06-01 16:50:19.387999-03	2026-06-05 13:24:20.306954-03
b48b5c54-c252-4ba9-a343-8ed9b2e71834	f758744f-983e-4d2f-8a73-c46734360258	66666666-6666-6666-6666-666666666666	Casquinha Simples	Casquinha com 1 bola	9.9	\N	t	/uploads/products/casquinha.png	2026-06-01 16:50:19.386847-03	2026-06-05 13:24:44.416765-03
842d9fd0-ead5-4ae0-aee4-28687d0305c8	f758744f-983e-4d2f-8a73-c46734360258	66666666-6666-6666-6666-666666666666	Gelato Chocolate Belga	Chocolate belga intenso	16.9	\N	t	/uploads/products/Gelato_Chocolate_Belga.png	2026-06-01 16:50:19.38434-03	2026-06-05 13:25:15.470543-03
be84b03c-e18a-4471-a430-f41e1b8ea67b	f758744f-983e-4d2f-8a73-c46734360258	66666666-6666-6666-6666-666666666666	Milk-shake Baunilha	Milk-shake artesanal de baunilha	20.9	\N	t	/uploads/products/milkshake-baunilha.png	2026-06-01 16:50:19.390519-03	2026-06-05 13:31:35.689547-03
204af529-6cb0-41e8-ba9c-2f18c9260c0a	fb08e19f-18eb-4c75-ade5-9030cc9d6834	22222222-2222-2222-2222-222222222222	Onion Rings	Anéis de cebola empanados	19.9	\N	t	/uploads/products/onion_rings.png	2026-06-01 16:50:19.378472-03	2026-06-05 13:35:09.176626-03
217f6fec-99fd-4f51-8ce0-ac0d10ce5fdb	fb08e19f-18eb-4c75-ade5-9030cc9d6834	22222222-2222-2222-2222-222222222222	Cheeseburger Clássico	Pão brioche, queijo cheddar e blend bovino	34.9	29.9	t	/uploads/products/chessburger.png	2026-06-01 16:50:19.351923-03	2026-06-05 13:35:34.491147-03
77641699-66ee-4a6b-9bda-add2eaa7d0f2	fb08e19f-18eb-4c75-ade5-9030cc9d6834	22222222-2222-2222-2222-222222222222	Batata Frita Grande	Porção generosa de batata frita	18.9	15.9	t	/uploads/products/batata_frita.png	2026-06-01 16:50:19.376989-03	2026-06-05 13:53:49.360474-03
a6374796-62c5-4dd6-a4f6-57d4e90d4c51	fb08e19f-18eb-4c75-ade5-9030cc9d6834	22222222-2222-2222-2222-222222222222	Bacon Burger	Hambúrguer com bacon crocante e molho especial	39.9	\N	t	/uploads/products/burger_bacon.png	2026-06-01 16:50:19.373781-03	2026-06-05 13:54:32.129163-03
e17c506a-8e53-485b-bf78-d46d8af84701	fb08e19f-18eb-4c75-ade5-9030cc9d6834	66666666-6666-6666-6666-666666666666	Milk-shake Chocolate	Milk-shake cremoso de chocolate	21.9	\N	t	/uploads/products/milkshake_chocolate.png	2026-06-01 16:50:19.38006-03	2026-06-05 13:54:57.588606-03
465259bf-ed38-413d-96b2-4cc34325eb7a	61234754-c18f-463c-8043-50ff1b5f21c7	44444444-4444-4444-4444-444444444444	Steak da Casa	Corte grelhado ao ponto	74.9	\N	t	/uploads/products/steake.png	2026-06-01 16:50:19.393119-03	2026-06-05 13:59:00.249642-03
544d9d6f-6c9e-495e-b146-da4900414cb8	61234754-c18f-463c-8043-50ff1b5f21c7	11111111-1111-1111-1111-111111111111	Limonada	Limonada da casa	12.9	\N	t	/uploads/products/limonada.png	2026-06-01 16:50:19.399582-03	2026-06-05 13:59:41.651171-03
56bc5dd6-33aa-4b90-b2fc-04fc73d150d1	61234754-c18f-463c-8043-50ff1b5f21c7	66666666-6666-6666-6666-666666666666	Cheesecake	Cheesecake com calda de frutas vermelhas	26.9	\N	t	/uploads/products/cheescake.png	2026-06-01 16:50:19.398369-03	2026-06-05 14:01:51.549712-03
688ce726-12a0-4bdc-b8cf-8fb95ecc2389	61234754-c18f-463c-8043-50ff1b5f21c7	44444444-4444-4444-4444-444444444444	Frango Grill	Peito de frango grelhado com legumes	49.9	\N	t	/uploads/products/frango_grill.png	2026-06-01 16:50:19.39428-03	2026-06-05 14:02:18.444812-03
6acb9cdb-2e32-478d-b04e-b170ecc826e7	61234754-c18f-463c-8043-50ff1b5f21c7	22222222-2222-2222-2222-222222222222	Bloom Onion	Cebola dourada especial	35.9	\N	t	/uploads/products/bloom-onion.png	2026-06-01 16:50:19.395641-03	2026-06-05 14:02:39.572759-03
d7242bfd-7653-4b56-8317-c613d1847dc9	61234754-c18f-463c-8043-50ff1b5f21c7	22222222-2222-2222-2222-222222222222	Batata Rustica	Batatas rústicas temperadas	24.9	\N	t	/uploads/products/batata_rustica.png	2026-06-01 16:50:19.396797-03	2026-06-05 14:04:49.428403-03
39564fc7-3fdd-4d1e-afd4-4cb68095fd70	bcb275af-0695-4493-8206-4b010d209436	11111111-1111-1111-1111-111111111111	Uramaki Filadélfia	8 unidades de uramaki filadélfia	29.9	\N	t	/uploads/products/urumaki.png	2026-06-01 16:50:19.403458-03	2026-06-05 14:06:38.729365-03
3b207ea5-4f32-4fab-bedc-041a6bc18857	bcb275af-0695-4493-8206-4b010d209436	11111111-1111-1111-1111-111111111111	Refrigerante Lata	Refrigerante 350ml	7.9	\N	t	/uploads/products/refrigerante_lata.png	2026-06-01 16:50:19.408413-03	2026-06-05 14:07:20.090975-03
7b14f09c-d8df-4b92-a3bb-94cbdf6fa581	bcb275af-0695-4493-8206-4b010d209436	11111111-1111-1111-1111-111111111111	Guioza	Porção com 6 unidades	21.9	\N	t	/uploads/products/guioza.png	2026-06-01 16:50:19.407208-03	2026-06-05 14:07:48.664968-03
81b5ebbd-164a-48b2-a4d6-1e8b2f00a962	bcb275af-0695-4493-8206-4b010d209436	11111111-1111-1111-1111-111111111111	Yakissoba Frango	Yakissoba de frango e legumes	34.9	\N	t	/uploads/products/yakissoba_frango.png	2026-06-01 16:50:19.405844-03	2026-06-05 14:09:08.702127-03
8a009c50-95e4-47b3-b952-49383d516ec2	bcb275af-0695-4493-8206-4b010d209436	11111111-1111-1111-1111-111111111111	Temaki Salmão	Temaki de salmão com cream cheese	24.9	\N	t	/uploads/products/temaki-salmao.png	2026-06-01 16:50:19.402185-03	2026-06-05 14:09:31.772877-03
d3ce24c7-3a43-4f1b-9744-ac414ee35ddc	bcb275af-0695-4493-8206-4b010d209436	11111111-1111-1111-1111-111111111111	Combo Sushi 20 peças	Seleção do chef com 20 peças	62.9	54.9	t	/uploads/products/combo_sushi.png	2026-06-01 16:50:19.401001-03	2026-06-05 14:10:15.158844-03
62f2683b-413b-4cbd-8661-8f605c5dfb0b	f890d712-48d4-4dbc-800f-341282bf3f1e	77777777-7777-7777-7777-777777777777	Bruschetta	Entrada com tomate e manjericão	22.9	\N	t	/uploads/products/bruscheta.png	2026-06-01 16:50:19.415219-03	2026-06-05 14:25:13.25503-03
81e5125e-6824-42c7-8ae1-4da2ccf66430	f890d712-48d4-4dbc-800f-341282bf3f1e	77777777-7777-7777-7777-777777777777	Fettuccine Alfredo	Fettuccine ao molho alfredo	39.9	34.9	t	/uploads/products/fetuttini_alfredo.png	2026-06-01 16:50:19.411098-03	2026-06-05 14:26:07.545941-03
91a05d93-14cf-4c99-a7be-8c1856f31b80	f890d712-48d4-4dbc-800f-341282bf3f1e	11111111-1111-1111-1111-111111111111	Suco de Uva	Suco integral de uva	13.9	\N	t	/uploads/products/suco_uva.png	2026-06-01 16:50:19.417661-03	2026-06-05 14:26:28.588742-03
a9b444c3-f219-4344-8b0d-0161b1c82fae	f890d712-48d4-4dbc-800f-341282bf3f1e	77777777-7777-7777-7777-777777777777	Risoto Funghi	Risoto de funghi com parmesão	46.9	\N	t	/uploads/products/risoto_funghi.png	2026-06-01 16:50:19.41359-03	2026-06-05 14:26:55.805584-03
ef456bab-85d3-434e-b6a6-f142f9c9975e	f890d712-48d4-4dbc-800f-341282bf3f1e	77777777-7777-7777-7777-777777777777	Lasanha Bolonhesa	Lasanha tradicional bolonhesa	44.9	\N	t	/uploads/products/lasanha_bolanhesa.png	2026-06-01 16:50:19.412333-03	2026-06-05 14:27:51.002259-03
04d91f95-83fa-4e53-aac1-5d54f7a3b9c4	bc8e1690-229d-46ca-8d13-d3b5fc167179	66666666-6666-6666-6666-666666666666	Churros	Churros com doce de leite	19.9	\N	t	/uploads/products/churros.png	2026-06-01 16:50:19.424843-03	2026-06-05 14:29:10.87967-03
59543087-5037-4eda-af43-2921d03a1e84	bc8e1690-229d-46ca-8d13-d3b5fc167179	88888888-8888-8888-8888-888888888888	Chilli com Carne	Chilli apimentado da casa	35.9	\N	t	/uploads/products/chilli_carne.png	2026-06-01 16:50:19.423696-03	2026-06-05 14:29:39.185892-03
63ca46df-09ec-4c25-9277-48d149ef0180	bc8e1690-229d-46ca-8d13-d3b5fc167179	11111111-1111-1111-1111-111111111111	Horchata	Bebida mexicana de arroz	12.9	\N	t	/uploads/products/horcata.png	2026-06-01 16:50:19.42601-03	2026-06-05 14:29:59.888109-03
756ba861-16d7-4f52-be9a-02fc4764a50b	bc8e1690-229d-46ca-8d13-d3b5fc167179	88888888-8888-8888-8888-888888888888	Tacos de Carne	3 tacos de carne temperada	31.9	27.9	t	/uploads/products/tacos_carne.png	2026-06-01 16:50:19.418942-03	2026-06-05 14:30:18.793885-03
bb70ea8d-3bb3-465e-bab8-dd107846f551	bc8e1690-229d-46ca-8d13-d3b5fc167179	88888888-8888-8888-8888-888888888888	Quesadilla Queijo	Quesadilla recheada com queijos	28.9	\N	t	/uploads/products/quesadila_queijo.png	2026-06-01 16:50:19.422476-03	2026-06-05 14:31:16.372968-03
ea9730de-540c-434b-a36f-ff90151726df	bc8e1690-229d-46ca-8d13-d3b5fc167179	88888888-8888-8888-8888-888888888888	Nachos Supreme	Nachos com queijo e chilli	29.9	\N	t	/uploads/products/nachos_supreme.png	2026-06-01 16:50:19.421333-03	2026-06-05 14:31:35.230811-03
0c2be935-cc3c-4490-b2a9-27da2ffa827c	e4a5873d-0949-4189-9ec2-e153f1a6894e	11111111-1111-1111-1111-111111111111	Açaí 300ml	Açaí tradicional com banana	18.9	\N	t	/uploads/products/açaí.png	2026-06-01 16:50:19.427473-03	2026-06-05 14:38:35.115023-03
185b7af8-7e77-49b0-be45-51db45cef472	e4a5873d-0949-4189-9ec2-e153f1a6894e	55555555-5555-5555-5555-555555555555	Salada de Frutas	Mix de frutas frescas	16.9	\N	t	/uploads/products/salada_frutas.png	2026-06-01 16:50:19.433186-03	2026-06-05 14:39:32.32696-03
907064ff-7d7a-4882-a416-bfcd6c806a42	e4a5873d-0949-4189-9ec2-e153f1a6894e	11111111-1111-1111-1111-111111111111	Açaí 500ml	Açaí com granola e leite condensado	24.9	21.9	t	/uploads/products/açaí.png	2026-06-01 16:50:19.428924-03	2026-06-05 14:40:21.580086-03
93ecd8a0-efbc-458a-be7f-f40da43a5db0	e4a5873d-0949-4189-9ec2-e153f1a6894e	11111111-1111-1111-1111-111111111111	Smoothie Morango	Smoothie natural de morango	17.9	\N	t	/uploads/products/smoothie_morango.png	2026-06-01 16:50:19.430236-03	2026-06-05 14:40:47.468269-03
d716d250-caa6-45c7-b073-1c3df5172f56	e4a5873d-0949-4189-9ec2-e153f1a6894e	55555555-5555-5555-5555-555555555555	Tapioca Frango	Tapioca recheada com frango	19.9	\N	t	/uploads/products/tapioca_frango.png	2026-06-01 16:50:19.434389-03	2026-06-05 14:41:21.078116-03
e9eff3ef-5e92-4207-8ef5-e8c7f6a13205	e4a5873d-0949-4189-9ec2-e153f1a6894e	eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee	Wrap Veggie	Wrap vegetariano com folhas	22.9	\N	t	/uploads/products/wrap_veggie.png	2026-06-01 16:50:19.43566-03	2026-06-05 14:41:46.150746-03
1a757d63-2c0b-400e-bd50-1c16c5cf0581	fb08e19f-18eb-4c75-ade5-9030cc9d6834	22222222-2222-2222-2222-222222222222	Chicken Crispy Burger	Frango empanado e maionese de ervas	32.9	\N	t	/uploads/products/chicken_crispy_burger.png	2026-06-01 16:50:19.375429-03	2026-06-05 13:34:23.558558-03
e79a14e9-aee9-407c-8c0f-63779db5bd72	fb08e19f-18eb-4c75-ade5-9030cc9d6834	22222222-2222-2222-2222-222222222222	Refrigerante Lata	Refrigerante 350ml	7.9	\N	t	/uploads/products/refrigerante_lata.png	2026-06-01 16:50:19.381812-03	2026-06-05 13:55:39.404116-03
be0d87ec-b2a3-450b-9bee-7401a10c7b09	61234754-c18f-463c-8043-50ff1b5f21c7	44444444-4444-4444-4444-444444444444	Ribs BBQ	Costela suína ao molho barbecue	79.9	69.9	t	/uploads/products/ribs_bbq.png	2026-06-01 16:50:19.391818-03	2026-06-05 14:03:07.16408-03
7c7d54fb-70aa-4231-be52-25403a6ed63c	bcb275af-0695-4493-8206-4b010d209436	11111111-1111-1111-1111-111111111111	Hot Roll	8 unidades de hot roll	27.9	\N	t	/uploads/products/hotholl.png	2026-06-01 16:50:19.404655-03	2026-06-05 14:08:43.276462-03
5f0a6a67-4c0b-4784-8fec-f81bb47fca5f	f890d712-48d4-4dbc-800f-341282bf3f1e	66666666-6666-6666-6666-666666666666	Tiramisu	Sobremesa clássica italiana	24.9	\N	t	/uploads/products/tiramisu.png	2026-06-01 16:50:19.416487-03	2026-06-05 14:24:42.083082-03
e2c113d3-95d0-4316-8e8d-23f9f68aecfa	f890d712-48d4-4dbc-800f-341282bf3f1e	77777777-7777-7777-7777-777777777777	Spaghetti Carbonara	Massa italiana com molho carbonara	42.9	\N	t	/uploads/products/spagetti_carbonara.png	2026-06-01 16:50:19.409691-03	2026-06-05 14:27:28.825344-03
a7808db6-015a-4c91-bbbd-6d8763becc82	bc8e1690-229d-46ca-8d13-d3b5fc167179	88888888-8888-8888-8888-888888888888	Burrito Frango	Burrito de frango com feijão	33.9	\N	t	/uploads/products/burrito_frango.png	2026-06-01 16:50:19.420203-03	2026-06-05 14:30:46.896087-03
57c9b504-c555-42ff-854e-a9726b072a04	e4a5873d-0949-4189-9ec2-e153f1a6894e	55555555-5555-5555-5555-555555555555	Suco Detox	Suco verde detox	14.9	\N	t	/uploads/products/suco_detox.png	2026-06-01 16:50:19.431855-03	2026-06-05 14:39:54.160399-03
\.


--
-- Data for Name: RestaurantCategories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."RestaurantCategories" ("Id", "Name") FROM stdin;
40c040be-c40e-4738-836c-2a7684465a33	Hamburgueria
5defaf08-8e94-4501-b16a-7c0d521747f4	Sorveteria
4982ba94-1a38-478d-bfb4-7bc76c4fc9f5	Churrascaria
37091196-f9a2-47e8-800e-93586545d623	Japonesa
4335402c-a020-49ed-af8e-28c71d80ef75	Italiana
a8fab887-2c57-46e1-a515-84c154a04197	Mexicana
53c69800-7a89-41c6-b86f-eea2fb0984aa	Açaí e Sucos
\.


--
-- Data for Name: Restaurants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Restaurants" ("Id", "Name", "Description", "Cnpj", "Phone", "Email", "IsOpen", "CategoryId", "CreatedAt", "UpdatedAt", "ProfileImageUrl") FROM stdin;
f758744f-983e-4d2f-8a73-c46734360258	Bacio di Latte	Unidade oficial de Bacio di Latte	00000526174140	11999999999	rest2@bacio.local	t	5defaf08-8e94-4501-b16a-7c0d521747f4	2026-06-01 16:50:19.177676-03	2026-06-05 13:21:10.741255-03	/uploads/logos/baciodilatte.jpeg
fb08e19f-18eb-4c75-ade5-9030cc9d6834	Madero Burger	Unidade oficial de Madero Burger	00001742375290	11999999999	rest1@madero.local	t	40c040be-c40e-4738-836c-2a7684465a33	2026-06-01 16:50:19.113376-03	2026-06-05 13:57:03.934285-03	/uploads/logos/madero.jpeg
61234754-c18f-463c-8043-50ff1b5f21c7	Outback Steakhouse	Unidade oficial de Outback Steakhouse	00002113289275	11999999999	rest3@outback.local	t	4982ba94-1a38-478d-bfb4-7bc76c4fc9f5	2026-06-01 16:50:19.206599-03	2026-06-05 13:58:01.491166-03	/uploads/logos/outback.jpeg
bcb275af-0695-4493-8206-4b010d209436	Sushi Yakuza	Unidade oficial de Sushi Yakuza	00001988625629	11999999999	rest4@sushi.local	t	37091196-f9a2-47e8-800e-93586545d623	2026-06-01 16:50:19.234261-03	2026-06-05 14:05:55.747517-03	/uploads/logos/sushi_yakuza.jpeg
bc8e1690-229d-46ca-8d13-d3b5fc167179	Taco Loco	Unidade oficial de Taco Loco	00000188476974	11999999999	rest6@taco.local	t	a8fab887-2c57-46e1-a515-84c154a04197	2026-06-01 16:50:19.290233-03	2026-06-05 14:28:46.200943-03	/uploads/logos/taco_loco.jpeg
e4a5873d-0949-4189-9ec2-e153f1a6894e	Açaí da Barra	Unidade oficial de Açaí da Barra	00001300655678	11999999999	rest7@acai.local	t	53c69800-7a89-41c6-b86f-eea2fb0984aa	2026-06-01 16:50:19.318941-03	2026-06-05 14:32:33.273628-03	/uploads/logos/acai_barra.jpeg
f890d712-48d4-4dbc-800f-341282bf3f1e	Cantina Italia	Unidade oficial de Cantina Italia	00001015133201	11999999999	rest5@cantina.local	t	4335402c-a020-49ed-af8e-28c71d80ef75	2026-06-01 16:50:19.261734-03	2026-06-05 14:42:38.701692-03	/uploads/logos/cantina_italia.jpeg
\.


--
-- Data for Name: Reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Reviews" ("Id", "CustomerId", "RestaurantId", "OrderId", "Rating", "Comment") FROM stdin;
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20260601170900_InitialPostgresDelivery	9.0.5
20260601193212_MakeMenuCategoriesGlobal	9.0.5
20260601193235_SeedMoreGlobalMenuCategories	9.0.5
20260601210317_AddCommentToCartItem	9.0.5
20260605160336_AddRestaurantProfileImageUrl	9.0.5
\.


--
-- Name: CartItems PK_CartItems; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItems"
    ADD CONSTRAINT "PK_CartItems" PRIMARY KEY ("Id");


--
-- Name: Carts PK_Carts; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Carts"
    ADD CONSTRAINT "PK_Carts" PRIMARY KEY ("Id");


--
-- Name: Coupons PK_Coupons; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Coupons"
    ADD CONSTRAINT "PK_Coupons" PRIMARY KEY ("Id");


--
-- Name: CustomerAddresses PK_CustomerAddresses; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerAddresses"
    ADD CONSTRAINT "PK_CustomerAddresses" PRIMARY KEY ("Id");


--
-- Name: Customers PK_Customers; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customers"
    ADD CONSTRAINT "PK_Customers" PRIMARY KEY ("Id");


--
-- Name: Deliveries PK_Deliveries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Deliveries"
    ADD CONSTRAINT "PK_Deliveries" PRIMARY KEY ("Id");


--
-- Name: DeliveryDrivers PK_DeliveryDrivers; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DeliveryDrivers"
    ADD CONSTRAINT "PK_DeliveryDrivers" PRIMARY KEY ("Id");


--
-- Name: MenuCategories PK_MenuCategories; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MenuCategories"
    ADD CONSTRAINT "PK_MenuCategories" PRIMARY KEY ("Id");


--
-- Name: OrderItems PK_OrderItems; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItems"
    ADD CONSTRAINT "PK_OrderItems" PRIMARY KEY ("Id");


--
-- Name: Orders PK_Orders; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "PK_Orders" PRIMARY KEY ("Id");


--
-- Name: Payments PK_Payments; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payments"
    ADD CONSTRAINT "PK_Payments" PRIMARY KEY ("Id");


--
-- Name: ProductOptionGroups PK_ProductOptionGroups; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductOptionGroups"
    ADD CONSTRAINT "PK_ProductOptionGroups" PRIMARY KEY ("Id");


--
-- Name: ProductOptions PK_ProductOptions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductOptions"
    ADD CONSTRAINT "PK_ProductOptions" PRIMARY KEY ("Id");


--
-- Name: Products PK_Products; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "PK_Products" PRIMARY KEY ("Id");


--
-- Name: RestaurantCategories PK_RestaurantCategories; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RestaurantCategories"
    ADD CONSTRAINT "PK_RestaurantCategories" PRIMARY KEY ("Id");


--
-- Name: Restaurants PK_Restaurants; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Restaurants"
    ADD CONSTRAINT "PK_Restaurants" PRIMARY KEY ("Id");


--
-- Name: Reviews PK_Reviews; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Reviews"
    ADD CONSTRAINT "PK_Reviews" PRIMARY KEY ("Id");


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: IX_CartItems_CartId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_CartItems_CartId" ON public."CartItems" USING btree ("CartId");


--
-- Name: IX_CustomerAddresses_CustomerId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_CustomerAddresses_CustomerId" ON public."CustomerAddresses" USING btree ("CustomerId");


--
-- Name: IX_Deliveries_DeliveryDriverId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Deliveries_DeliveryDriverId" ON public."Deliveries" USING btree ("DeliveryDriverId");


--
-- Name: IX_Deliveries_OrderId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Deliveries_OrderId" ON public."Deliveries" USING btree ("OrderId");


--
-- Name: IX_OrderItems_OrderId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_OrderItems_OrderId" ON public."OrderItems" USING btree ("OrderId");


--
-- Name: IX_Orders_CustomerId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Orders_CustomerId" ON public."Orders" USING btree ("CustomerId");


--
-- Name: IX_Orders_RestaurantId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Orders_RestaurantId" ON public."Orders" USING btree ("RestaurantId");


--
-- Name: IX_Payments_OrderId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Payments_OrderId" ON public."Payments" USING btree ("OrderId");


--
-- Name: IX_ProductOptionGroups_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_ProductOptionGroups_ProductId" ON public."ProductOptionGroups" USING btree ("ProductId");


--
-- Name: IX_ProductOptions_ProductOptionGroupId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_ProductOptions_ProductOptionGroupId" ON public."ProductOptions" USING btree ("ProductOptionGroupId");


--
-- Name: IX_Products_MenuCategoryId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Products_MenuCategoryId" ON public."Products" USING btree ("MenuCategoryId");


--
-- Name: IX_Products_RestaurantId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Products_RestaurantId" ON public."Products" USING btree ("RestaurantId");


--
-- Name: IX_Restaurants_CategoryId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Restaurants_CategoryId" ON public."Restaurants" USING btree ("CategoryId");


--
-- Name: IX_Reviews_CustomerId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Reviews_CustomerId" ON public."Reviews" USING btree ("CustomerId");


--
-- Name: IX_Reviews_OrderId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Reviews_OrderId" ON public."Reviews" USING btree ("OrderId");


--
-- Name: IX_Reviews_RestaurantId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Reviews_RestaurantId" ON public."Reviews" USING btree ("RestaurantId");


--
-- Name: CartItems FK_CartItems_Carts_CartId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItems"
    ADD CONSTRAINT "FK_CartItems_Carts_CartId" FOREIGN KEY ("CartId") REFERENCES public."Carts"("Id") ON DELETE CASCADE;


--
-- Name: CustomerAddresses FK_CustomerAddresses_Customers_CustomerId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CustomerAddresses"
    ADD CONSTRAINT "FK_CustomerAddresses_Customers_CustomerId" FOREIGN KEY ("CustomerId") REFERENCES public."Customers"("Id") ON DELETE CASCADE;


--
-- Name: Deliveries FK_Deliveries_DeliveryDrivers_DeliveryDriverId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Deliveries"
    ADD CONSTRAINT "FK_Deliveries_DeliveryDrivers_DeliveryDriverId" FOREIGN KEY ("DeliveryDriverId") REFERENCES public."DeliveryDrivers"("Id");


--
-- Name: Deliveries FK_Deliveries_Orders_OrderId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Deliveries"
    ADD CONSTRAINT "FK_Deliveries_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES public."Orders"("Id") ON DELETE CASCADE;


--
-- Name: OrderItems FK_OrderItems_Orders_OrderId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItems"
    ADD CONSTRAINT "FK_OrderItems_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES public."Orders"("Id") ON DELETE CASCADE;


--
-- Name: Orders FK_Orders_Customers_CustomerId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "FK_Orders_Customers_CustomerId" FOREIGN KEY ("CustomerId") REFERENCES public."Customers"("Id") ON DELETE CASCADE;


--
-- Name: Orders FK_Orders_Restaurants_RestaurantId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "FK_Orders_Restaurants_RestaurantId" FOREIGN KEY ("RestaurantId") REFERENCES public."Restaurants"("Id") ON DELETE CASCADE;


--
-- Name: Payments FK_Payments_Orders_OrderId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payments"
    ADD CONSTRAINT "FK_Payments_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES public."Orders"("Id") ON DELETE CASCADE;


--
-- Name: ProductOptionGroups FK_ProductOptionGroups_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductOptionGroups"
    ADD CONSTRAINT "FK_ProductOptionGroups_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE CASCADE;


--
-- Name: ProductOptions FK_ProductOptions_ProductOptionGroups_ProductOptionGroupId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductOptions"
    ADD CONSTRAINT "FK_ProductOptions_ProductOptionGroups_ProductOptionGroupId" FOREIGN KEY ("ProductOptionGroupId") REFERENCES public."ProductOptionGroups"("Id") ON DELETE CASCADE;


--
-- Name: Products FK_Products_MenuCategories_MenuCategoryId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "FK_Products_MenuCategories_MenuCategoryId" FOREIGN KEY ("MenuCategoryId") REFERENCES public."MenuCategories"("Id") ON DELETE CASCADE;


--
-- Name: Products FK_Products_Restaurants_RestaurantId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "FK_Products_Restaurants_RestaurantId" FOREIGN KEY ("RestaurantId") REFERENCES public."Restaurants"("Id") ON DELETE CASCADE;


--
-- Name: Restaurants FK_Restaurants_RestaurantCategories_CategoryId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Restaurants"
    ADD CONSTRAINT "FK_Restaurants_RestaurantCategories_CategoryId" FOREIGN KEY ("CategoryId") REFERENCES public."RestaurantCategories"("Id") ON DELETE CASCADE;


--
-- Name: Reviews FK_Reviews_Customers_CustomerId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Reviews"
    ADD CONSTRAINT "FK_Reviews_Customers_CustomerId" FOREIGN KEY ("CustomerId") REFERENCES public."Customers"("Id") ON DELETE CASCADE;


--
-- Name: Reviews FK_Reviews_Orders_OrderId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Reviews"
    ADD CONSTRAINT "FK_Reviews_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES public."Orders"("Id") ON DELETE CASCADE;


--
-- Name: Reviews FK_Reviews_Restaurants_RestaurantId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Reviews"
    ADD CONSTRAINT "FK_Reviews_Restaurants_RestaurantId" FOREIGN KEY ("RestaurantId") REFERENCES public."Restaurants"("Id") ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 9ME10hQZKrcwXjnhXOdGI13PEqd4alQGnWp1Ex7mEvbG6wvl83Cc0gLu37WO2IN

--
-- Database "idelivery_identity" dump
--

--
-- PostgreSQL database dump
--

\restrict lIJU1hLZGb7ushpPTJtdKBaL3DPYB5j9QGwXhWchUSAs6bD2Ukjp9mX6fBfW3qc

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: idelivery_identity; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE idelivery_identity WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Portuguese_Brazil.1252';


ALTER DATABASE idelivery_identity OWNER TO postgres;

\unrestrict lIJU1hLZGb7ushpPTJtdKBaL3DPYB5j9QGwXhWchUSAs6bD2Ukjp9mX6fBfW3qc
\connect idelivery_identity
\restrict lIJU1hLZGb7ushpPTJtdKBaL3DPYB5j9QGwXhWchUSAs6bD2Ukjp9mX6fBfW3qc

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: RefreshTokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RefreshTokens" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "Token" text NOT NULL,
    "ExpiresAt" timestamp with time zone NOT NULL,
    "ReplacedByToken" text,
    "RevokedAt" timestamp with time zone
);


ALTER TABLE public."RefreshTokens" OWNER TO postgres;

--
-- Name: Roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Roles" (
    "Id" uuid NOT NULL,
    "Name" integer NOT NULL
);


ALTER TABLE public."Roles" OWNER TO postgres;

--
-- Name: UserRoles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."UserRoles" (
    "UserId" uuid NOT NULL,
    "RoleId" uuid NOT NULL
);


ALTER TABLE public."UserRoles" OWNER TO postgres;

--
-- Name: Users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Users" (
    "Id" uuid NOT NULL,
    "Email" text NOT NULL,
    "PasswordHash" text NOT NULL,
    "CustomerId" uuid,
    "DeliveryDriverId" uuid,
    "Name" text DEFAULT ''::text NOT NULL,
    "RestaurantId" uuid
);


ALTER TABLE public."Users" OWNER TO postgres;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- Data for Name: RefreshTokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."RefreshTokens" ("Id", "UserId", "Token", "ExpiresAt", "ReplacedByToken", "RevokedAt") FROM stdin;
be24e106-22d7-47c9-a37f-f92c9971b251	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	53aacc950b1442b9acec815859dcb377	2026-06-08 14:52:36.98059-03	\N	\N
155f7de8-b13e-4554-950b-ab3b7926f54d	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	327754807a4a4bda8cb4f74c83ba320a	2026-06-08 14:52:44.603472-03	\N	\N
60f4efdb-1335-4e9e-bf9a-7cbd8a1b4e2f	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	ba4ae683607b40c0a923be8666498e6c	2026-06-08 14:52:54.281564-03	\N	\N
1164c723-c7df-4a01-80a6-505d01997981	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	b94f649ef5fb4443959c08e9f0c5e916	2026-06-08 15:45:32.427714-03	\N	\N
841912cb-ece4-46e2-9f55-6c77e26eeab2	69fbb7b5-ac95-4c74-940f-d76f5c17a6d8	04ff9a5afd734a509a8dde349f6051f9	2026-06-08 15:46:48.683844-03	\N	\N
c93062df-bce3-4e46-82c5-2418c82bc5d9	69fbb7b5-ac95-4c74-940f-d76f5c17a6d8	c07be049b45c426bb1aeb8ba368543d0	2026-06-08 15:51:06.208213-03	\N	\N
45502cdd-2e73-4a60-91b1-060a7ce7bd4f	ae66e468-3833-40d2-89cd-45aaa1fddfdb	b335acf01eec4e21b7195eeb4c01a039	2026-06-08 15:53:18.532319-03	\N	\N
455250af-3f09-42e9-882f-93a4b36dd9dc	ae66e468-3833-40d2-89cd-45aaa1fddfdb	ec434b1ef149455e85fc2d2c6d2fe3f2	2026-06-08 16:09:13.48361-03	\N	\N
70b89eee-fd29-425e-a542-d637fd6c9ea8	e0390db2-cdc4-4f49-930f-e3bf2164ca67	af6bd59fda2e4766afddebeb4927eb27	2026-06-08 16:09:58.90548-03	\N	\N
e0471ed4-ed83-4822-aa3f-b6e80b5e1bcf	4b6e88c5-635a-43de-b023-1d97ded238ec	7d559189c13f4a2880405366dfedbd62	2026-06-08 16:51:04.746542-03	\N	\N
bf7ff930-850a-4833-9df1-677f6a01dc89	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	bb119256078f464da256c8f2fcd47c6e	2026-06-09 15:39:55.833763-03	\N	\N
5cc223e3-a731-4e47-9cb5-8696d9f6aa05	69fbb7b5-ac95-4c74-940f-d76f5c17a6d8	51143ec6f366443da4385daa5cbd6fd0	2026-06-09 16:50:14.288402-03	\N	\N
c8a9429a-55de-4679-9e45-19998d6147bf	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	c277a00cca0d4fac8e8d44dc01637887	2026-06-09 17:04:41.250696-03	\N	\N
5b58c1f7-df2d-4920-8f22-86b80e36cef6	69fbb7b5-ac95-4c74-940f-d76f5c17a6d8	919db449f85b49a5b1f7fe5ac92c8b11	2026-06-09 17:05:01.219652-03	\N	\N
0e33f1ef-0ce7-4162-9f60-8ce5a346e449	b5e37a59-4ee9-4758-823f-61bf8b38f93b	a9d274e62b264ac7a80bd23a4b83c4c5	2026-06-09 17:07:44.801744-03	\N	\N
b41c31ea-768d-4c3d-8ac1-a8b9ed9262e9	b5e37a59-4ee9-4758-823f-61bf8b38f93b	a6d3c70faad448d688c799c47a9db3d9	2026-06-09 17:07:59.148054-03	\N	\N
819b954c-0b29-4e38-a32f-afd25976d980	e7447bf7-7c90-4162-b395-6a3f2695c455	e201d10bc0134bf58346c70b2f3de555	2026-06-09 17:09:01.469659-03	\N	\N
96e067ee-ae75-4af3-87a4-93a338eb6f44	153e15d0-3cc3-4db1-b416-21c99586d99f	b0bfcacc36d441dabfbbfdd637c021c1	2026-06-09 17:14:30.016903-03	\N	\N
73dc5500-c038-4795-9cf1-c5d1e18b8a02	153e15d0-3cc3-4db1-b416-21c99586d99f	73982120c0cf4919a32137b1e2df5d95	2026-06-09 17:15:02.857896-03	\N	\N
de0f8e93-d40c-41e5-94cc-2fc0af2c2542	cd41bce7-6dcd-43e4-9d88-75197d131fcf	913fbcf74c7a4fd3bb5d7a40fe98240e	2026-06-09 17:15:57.54616-03	\N	\N
10152fed-2cc9-4033-a03d-8e1892c66a74	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	2052ccbc51bc45a489742355bb725d54	2026-06-09 17:23:32.375865-03	\N	\N
d62bf389-591a-4fd7-b867-56a3b17838f1	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	fd59cbf37fdc498097c283e826f0bb5f	2026-06-09 17:24:29.980584-03	\N	\N
d2b5c9d4-77f8-48e6-b63c-43aa36d9482a	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	eb8e1322b51945a2b26aa1be2c866d86	2026-06-09 17:24:34.68447-03	\N	\N
2682078d-ed71-42af-adc8-9c322bf82e77	153e15d0-3cc3-4db1-b416-21c99586d99f	10bea2f113fc44b894eb3b4c4bf810a1	2026-06-09 17:25:44.315587-03	\N	\N
7e8ca02c-b41e-4ec3-8867-f574f1de2811	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	f2212217d5c847febec69df0ed0c6a9b	2026-06-09 17:26:40.486845-03	\N	\N
9c53e93a-1ae5-41c5-a3d6-b780cb998538	cd41bce7-6dcd-43e4-9d88-75197d131fcf	4ea7d9f18acd493596b0b6aeaa3ee15b	2026-06-09 17:26:58.954484-03	\N	\N
6c248168-4d5a-4d97-b105-148bb69d5ee5	153e15d0-3cc3-4db1-b416-21c99586d99f	4fdf1c10b7fb48e0a6b28eb04e99c74e	2026-06-09 17:27:25.926886-03	\N	\N
851b7eab-dc34-464f-91f6-32e074bf4b75	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	c5cc1bd753c94e16874e04d4acc93f4f	2026-06-09 17:33:08.663219-03	\N	\N
beb7b875-2876-4220-a038-0ec3fdd17602	13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	6277ac7f32f344ae81ebbd9d8260e0c7	2026-06-09 18:12:00.240641-03	\N	\N
3033a113-a2b1-446f-bffd-0fa966e2d921	153e15d0-3cc3-4db1-b416-21c99586d99f	82e88bd9b6d34a60950d1bb32e46cc17	2026-06-09 18:12:33.08599-03	\N	\N
217eb0d8-0acd-4774-aa85-9c2a96ebd733	cd41bce7-6dcd-43e4-9d88-75197d131fcf	8ce48edf65d3462fabf53dda5a15768b	2026-06-09 18:12:59.67542-03	\N	\N
dd58c5a4-42b3-416c-9d74-f8d1b5515fe9	cd41bce7-6dcd-43e4-9d88-75197d131fcf	980e51195b787c99616d4f021b085274b1c358af11a2db90b60aeb4eb4237906	2026-06-10 11:01:22.501327-03	\N	\N
27de0b28-34e5-43d4-9be4-0f5e3df53128	cd41bce7-6dcd-43e4-9d88-75197d131fcf	61f19be9bd299c49e7fd5c97c1e609a40cadddcbf6a0052ab2bdc34e2f006f7e	2026-06-12 13:20:45.891142-03	\N	2026-06-05 13:31:46.051655-03
163593e8-127f-4833-a33a-7a1ff479dbd5	4b6e88c5-635a-43de-b023-1d97ded238ec	1f3b38ba4074c8b2fb0377fb27aa154272c455d92059bb23f85ad5c1869d3c15	2026-06-12 13:32:54.87796-03	a92bef77d9914e28b4e04afd13a45dda8f1d73e6bbdbf337ce8c9f50c0f6a81c	2026-06-05 13:33:39.858134-03
37d95a97-261f-4f3d-a7eb-12bab3a946c6	4b6e88c5-635a-43de-b023-1d97ded238ec	a92bef77d9914e28b4e04afd13a45dda8f1d73e6bbdbf337ce8c9f50c0f6a81c	2026-06-12 13:33:39.858422-03	fefe12aadff8c0ef55f1aff6bf1a6e6d7d501d46dff574516095961ce82d2faa	2026-06-05 13:34:23.537813-03
68726625-dc2b-427f-8b26-70175fca1349	4b6e88c5-635a-43de-b023-1d97ded238ec	fefe12aadff8c0ef55f1aff6bf1a6e6d7d501d46dff574516095961ce82d2faa	2026-06-12 13:34:23.537822-03	\N	2026-06-05 13:56:15.30669-03
d63e93c7-2f37-480e-a5a2-93b8e5eaa241	4b6e88c5-635a-43de-b023-1d97ded238ec	f6b62b732dc6ff51f70161946110f6245f3bb548cc27c79204df278df73ecc02	2026-06-12 13:56:55.099968-03	\N	2026-06-05 13:57:27.890148-03
4c34c24a-eecd-42ef-9489-4e15293052e6	7c7bba5b-8e51-49ab-a487-eea562cad864	3adb04816f64ce0a2c3b7bee1c76ea3fdbecd1b22ce1d3812d4fbdae2ef51840	2026-06-12 13:57:38.853139-03	\N	2026-06-05 14:05:07.499282-03
de1bc938-b9d2-4339-8535-4e7d97c0c07b	0cc4cfbe-4742-41b1-9b2d-0ade86cd123b	a5694faa14d70c1a610a44afd189bb6eda76fb309cb257245b85d436c4a099b5	2026-06-12 14:05:24.227765-03	\N	2026-06-05 14:11:08.975438-03
d31e99ef-bfeb-4187-b569-c3c5f7bae870	e24b86e0-ae05-4f52-9f18-46c8e107f421	31d980a6afcbbdb1d7d00a8eb4ad722827778be7e77f05b53bf842cdd0acbbaf	2026-06-12 14:11:22.266771-03	\N	2026-06-05 14:27:57.413287-03
b7ed96ce-936c-4be0-8d26-ada82b05d608	2a03733e-923f-4d41-a967-733a03356012	19c62f6a3b5ae12ab7f410e06c777db3cd534f14a4131f6a69c09386c35ff30f	2026-06-12 14:28:18.361969-03	\N	2026-06-05 14:31:41.335964-03
cad626fd-1233-45a7-b09c-cac62e28a3a0	7c32056c-1fe9-485e-9ea3-3755c0f06c98	1f97e8cd8b2e8ec4154c8f81e02157f6a1d9d637230f9718b399fd3cb522c3e7	2026-06-12 14:31:52.767395-03	\N	2026-06-05 14:42:02.19498-03
aa19296b-d1ee-40fd-8953-300515cb2398	e24b86e0-ae05-4f52-9f18-46c8e107f421	a97642d130743614a98e27d0dee1cb07e1c7441bb974524ccd67f795ba275506	2026-06-12 14:42:14.324406-03	\N	2026-06-05 14:42:45.324706-03
\.


--
-- Data for Name: Roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Roles" ("Id", "Name") FROM stdin;
35082c36-dd0e-4e92-a6b6-47499beb1560	0
61d0be79-9974-430a-8ea4-ba9cebc05448	2
75c03f98-55d0-4f17-b644-6ee738548c4d	3
93b9aaf7-61b1-4a93-a0db-0080e2f68efa	1
\.


--
-- Data for Name: UserRoles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."UserRoles" ("UserId", "RoleId") FROM stdin;
b5e37a59-4ee9-4758-823f-61bf8b38f93b	35082c36-dd0e-4e92-a6b6-47499beb1560
e7447bf7-7c90-4162-b395-6a3f2695c455	93b9aaf7-61b1-4a93-a0db-0080e2f68efa
a463ff52-efee-46e2-9405-6cb31bb89820	61d0be79-9974-430a-8ea4-ba9cebc05448
153e15d0-3cc3-4db1-b416-21c99586d99f	75c03f98-55d0-4f17-b644-6ee738548c4d
13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	93b9aaf7-61b1-4a93-a0db-0080e2f68efa
69fbb7b5-ac95-4c74-940f-d76f5c17a6d8	75c03f98-55d0-4f17-b644-6ee738548c4d
ae66e468-3833-40d2-89cd-45aaa1fddfdb	61d0be79-9974-430a-8ea4-ba9cebc05448
e0390db2-cdc4-4f49-930f-e3bf2164ca67	61d0be79-9974-430a-8ea4-ba9cebc05448
4b6e88c5-635a-43de-b023-1d97ded238ec	61d0be79-9974-430a-8ea4-ba9cebc05448
cd41bce7-6dcd-43e4-9d88-75197d131fcf	61d0be79-9974-430a-8ea4-ba9cebc05448
7c7bba5b-8e51-49ab-a487-eea562cad864	61d0be79-9974-430a-8ea4-ba9cebc05448
0cc4cfbe-4742-41b1-9b2d-0ade86cd123b	61d0be79-9974-430a-8ea4-ba9cebc05448
e24b86e0-ae05-4f52-9f18-46c8e107f421	61d0be79-9974-430a-8ea4-ba9cebc05448
2a03733e-923f-4d41-a967-733a03356012	61d0be79-9974-430a-8ea4-ba9cebc05448
7c32056c-1fe9-485e-9ea3-3755c0f06c98	61d0be79-9974-430a-8ea4-ba9cebc05448
\.


--
-- Data for Name: Users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Users" ("Id", "Email", "PasswordHash", "CustomerId", "DeliveryDriverId", "Name", "RestaurantId") FROM stdin;
b5e37a59-4ee9-4758-823f-61bf8b38f93b	admin@idelivery.local	iIl6xm3WmaMkqsxDx23aZA==:sZEEPHVdM958b0M23SJiNceTdiSN/uZl3g0FwbwmZhs=	\N	\N		\N
a463ff52-efee-46e2-9405-6cb31bb89820	owner@idelivery.local	Hou+IkxlGumbz8mDEWMhpQ==:nLPtQCU/dqte7TSxN06qLgODGxSRoPVTctWmG6Zi2Wk=	\N	\N		\N
13e5ad1d-2e2a-44b5-a094-4b58beeb34cc	cliente@cliente.com	iuqXm/KjRZkOZsGesiA/PQ==:dAELfPiVvj31OzelvsXNJRmUoouXTpkz42Qa/38T/Uk=	\N	\N		\N
69fbb7b5-ac95-4c74-940f-d76f5c17a6d8	entregador@entregador.com	gI2k/E6Ew0Y5bFEw91YEsg==:aucqXhBnseZEf0XFu3KZXZYD4nGeDwsG/GhHjJZzAfc=	\N	\N		\N
ae66e468-3833-40d2-89cd-45aaa1fddfdb	kozan@restaurante.com	Ak3Hc18u8Q+RqHrZu7hMGQ==:9rpqvdA0FLf6z6f/cjBB8gIQRan+j/x3cJraOpkyRtw=	\N	\N		\N
e0390db2-cdc4-4f49-930f-e3bf2164ca67	kozanoficial@restaurante.com	cOlA3xUbh+IhQrj14/1mPw==:awqomUQfbPQR5x8AE1YOccb0/8QM3L/lAnuD6bLTdu0=	\N	\N	Kozan	\N
153e15d0-3cc3-4db1-b416-21c99586d99f	driver@idelivery.local	RjlLig0BE9N4o9i1EABpJg==:MtUjxVXBm7WrhinUaW6s6scCgPI/gEp3C5oMzNfuULQ=	\N	9f0fc25e-1f8f-42ad-a714-90cc43699ee5		\N
e7447bf7-7c90-4162-b395-6a3f2695c455	customer@idelivery.local	mWQiiZQl+0k+imVzHx8FMw==:rFKWip4V+miq1lwftBxbN+K54emG2jq/Vfeq+WzsYBs=	e75ba7c0-4ea0-4b75-b300-ca3a85a0a7d3	\N		\N
4b6e88c5-635a-43de-b023-1d97ded238ec	rest1@madero.local	zrG1DtFD9NmX7jJiA7vxpQ==:3vxWYpIKzYtsUTCYdSTjZmpUUZaF5YnELJ2djS9OZrs=	\N	\N	Madero Burger	fb08e19f-18eb-4c75-ade5-9030cc9d6834
cd41bce7-6dcd-43e4-9d88-75197d131fcf	rest2@bacio.local	tiKa8ZTGEvhba4R/CqLCjQ==:FXve7ZSfpgwj+xquVVH+ifwC6phIgGcdKbzOtLc07h8=	\N	\N	Bacio di Latte	f758744f-983e-4d2f-8a73-c46734360258
7c7bba5b-8e51-49ab-a487-eea562cad864	rest3@outback.local	90giuOeuJNMRKB2fGTbKUQ==:eYuyH7DqBdlk1bjJElNq5YkJRas9APZ139r0qE8p/Q4=	\N	\N	Outback Steakhouse	61234754-c18f-463c-8043-50ff1b5f21c7
0cc4cfbe-4742-41b1-9b2d-0ade86cd123b	rest4@sushi.local	a2UOxRh1cGtzl3Si+3RHsg==:/hWYym0BSc69Klzrwwoj4K171NKAAcH/oIRZjmp7sHI=	\N	\N	Sushi Yakuza	bcb275af-0695-4493-8206-4b010d209436
e24b86e0-ae05-4f52-9f18-46c8e107f421	rest5@cantina.local	pFZZsaXZiYiTTtfHA7yZ9A==:AgZ9TIBqLFczLV2nFqm53wlSpkubWajcucbn4iNJIqY=	\N	\N	Cantina Italia	f890d712-48d4-4dbc-800f-341282bf3f1e
2a03733e-923f-4d41-a967-733a03356012	rest6@taco.local	rHFcCQyvI+nLxBxV/G2Ouw==:PrChhNaMXQnDp/Q/I2WQaB/yu/LPpGGJf+Mu0xTPc44=	\N	\N	Taco Loco	bc8e1690-229d-46ca-8d13-d3b5fc167179
7c32056c-1fe9-485e-9ea3-3755c0f06c98	rest7@acai.local	yVtDkxDY8gGd1zAYm5ZeyQ==:6qAvZTwcE3nxnF6GFDy0ePHE6Ty7tnxoESrYUOyXmkM=	\N	\N	Açaí da Barra	e4a5873d-0949-4189-9ec2-e153f1a6894e
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20260601170901_InitialPostgresIdentity	9.0.5
20260601190249_AddUserNameToIdentityUser	9.0.5
20260603122150_AddRestaurantIdToIdentityUser	9.0.5
20260603124513_AddRefreshTokenRevocation	9.0.5
\.


--
-- Name: RefreshTokens PK_RefreshTokens; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RefreshTokens"
    ADD CONSTRAINT "PK_RefreshTokens" PRIMARY KEY ("Id");


--
-- Name: Roles PK_Roles; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Roles"
    ADD CONSTRAINT "PK_Roles" PRIMARY KEY ("Id");


--
-- Name: UserRoles PK_UserRoles; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."UserRoles"
    ADD CONSTRAINT "PK_UserRoles" PRIMARY KEY ("UserId", "RoleId");


--
-- Name: Users PK_Users; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Users"
    ADD CONSTRAINT "PK_Users" PRIMARY KEY ("Id");


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: IX_RefreshTokens_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_RefreshTokens_UserId" ON public."RefreshTokens" USING btree ("UserId");


--
-- Name: IX_UserRoles_RoleId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_UserRoles_RoleId" ON public."UserRoles" USING btree ("RoleId");


--
-- Name: RefreshTokens FK_RefreshTokens_Users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RefreshTokens"
    ADD CONSTRAINT "FK_RefreshTokens_Users_UserId" FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE;


--
-- Name: UserRoles FK_UserRoles_Roles_RoleId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."UserRoles"
    ADD CONSTRAINT "FK_UserRoles_Roles_RoleId" FOREIGN KEY ("RoleId") REFERENCES public."Roles"("Id") ON DELETE CASCADE;


--
-- Name: UserRoles FK_UserRoles_Users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."UserRoles"
    ADD CONSTRAINT "FK_UserRoles_Users_UserId" FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict lIJU1hLZGb7ushpPTJtdKBaL3DPYB5j9QGwXhWchUSAs6bD2Ukjp9mX6fBfW3qc

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

\restrict pOYtc1GzneCfQoG7QjAfOxy3gh7TFhOXJM14iRbLufcmqnG57V2sGP23MFCrfM8

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

\unrestrict pOYtc1GzneCfQoG7QjAfOxy3gh7TFhOXJM14iRbLufcmqnG57V2sGP23MFCrfM8

--
-- PostgreSQL database cluster dump complete
--

