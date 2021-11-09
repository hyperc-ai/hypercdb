--
-- PostgreSQL database dump
--
TRANSIT INIT;

-- Dumped from database version 12.8 (Ubuntu 12.8-1.pgdg20.04+1)
-- Dumped by pg_dump version 14.0 (Ubuntu 14.0-1.pgdg20.04+1)

-- Started on 2021-10-27 08:44:08 PDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3015 (class 1262 OID 16385)
-- Name: testdb; Type: DATABASE; Schema: -; Owner: postgres
--

\connect testdb

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- TOC entry 208 (class 1259 OID 16446)
-- Name: location_adjacency; Type: TABLE; Schema: public; Owner: pguser
--

CREATE TABLE public.location_adjacency (
    user_id integer NOT NULL,
    loc_a character varying(50) NOT NULL,
    loc_b character varying(50) NOT NULL,
    distance integer NOT NULL
);


ALTER TABLE public.location_adjacency OWNER TO pguser;

--
-- TOC entry 206 (class 1259 OID 16436)
-- Name: trucks; Type: TABLE; Schema: public; Owner: pguser
--

CREATE TABLE public.trucks (
    user_id integer NOT NULL,
    name character varying(50) PRIMARY KEY NOT NULL,
    odometer integer,
    location character varying(50) NOT NULL
);


ALTER TABLE public.trucks OWNER TO pguser;

--
-- TOC entry 212 (class 1255 OID 16453)
-- Name: move_truck_p(public.trucks, public.location_adjacency); Type: PROCEDURE; Schema: public; Owner: pguser
--

CREATE PROCEDURE public.move_truck_p(t public.trucks, l public.location_adjacency)
    LANGUAGE hyperc
    AS $$
assert t.LOCATION == l.LOC_A
t.LOCATION = l.LOC_B
t.ODOMETER += l.DISTANCE
$$;


ALTER PROCEDURE public.move_truck_p(t public.trucks, l public.location_adjacency) OWNER TO pguser;

--
-- TOC entry 211 (class 1259 OID 32869)
-- Name: drivers; Type: TABLE; Schema: public; Owner: pguser
--

CREATE TABLE public.drivers (
    name character varying(50),
    location character varying(50)
);


ALTER TABLE public.drivers OWNER TO pguser;

--
-- TOC entry 207 (class 1259 OID 16444)
-- Name: location_adjacency_user_id_seq; Type: SEQUENCE; Schema: public; Owner: pguser
--

CREATE SEQUENCE public.location_adjacency_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.location_adjacency_user_id_seq OWNER TO pguser;

--
-- TOC entry 3019 (class 0 OID 0)
-- Dependencies: 207
-- Name: location_adjacency_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pguser
--

ALTER SEQUENCE public.location_adjacency_user_id_seq OWNED BY public.location_adjacency.user_id;


--
-- TOC entry 205 (class 1259 OID 16434)
-- Name: trucks_user_id_seq; Type: SEQUENCE; Schema: public; Owner: pguser
--

CREATE SEQUENCE public.trucks_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trucks_user_id_seq OWNER TO pguser;

--
-- TOC entry 3020 (class 0 OID 0)
-- Dependencies: 205
-- Name: trucks_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pguser
--

ALTER SEQUENCE public.trucks_user_id_seq OWNED BY public.trucks.user_id;

--
-- TOC entry 2860 (class 2604 OID 16449)
-- Name: location_adjacency user_id; Type: DEFAULT; Schema: public; Owner: pguser
--

ALTER TABLE ONLY public.location_adjacency ALTER COLUMN user_id SET DEFAULT nextval('public.location_adjacency_user_id_seq'::regclass);


--
-- TOC entry 2859 (class 2604 OID 16439)
-- Name: trucks user_id; Type: DEFAULT; Schema: public; Owner: pguser
--

ALTER TABLE ONLY public.trucks ALTER COLUMN user_id SET DEFAULT nextval('public.trucks_user_id_seq'::regclass);


--
-- TOC entry 3006 (class 0 OID 16446)
-- Dependencies: 208
-- Data for Name: location_adjacency; Type: TABLE DATA; Schema: public; Owner: pguser
--

INSERT INTO public.location_adjacency (user_id, loc_a, loc_b, distance) VALUES (1, 'Home', '1st JCT', 2);
INSERT INTO public.location_adjacency (user_id, loc_a, loc_b, distance) VALUES (2, '1st JCT', 'Willows', 3);
INSERT INTO public.location_adjacency (user_id, loc_a, loc_b, distance) VALUES (3, 'Willows', 'Office', 2);


--
-- TOC entry 3004 (class 0 OID 16436)
-- Dependencies: 206
-- Data for Name: trucks; Type: TABLE DATA; Schema: public; Owner: pguser
--

INSERT INTO public.trucks (user_id, name, odometer, location) VALUES (2, 'Truck 2', 0, 'Office');
INSERT INTO public.trucks (user_id, name, odometer, location) VALUES (1, 'Truck 1', 0, 'Home');


--
-- TOC entry 3023 (class 0 OID 0)
-- Dependencies: 207
-- Name: location_adjacency_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pguser
--

SELECT pg_catalog.setval('public.location_adjacency_user_id_seq', 3, true);


--
-- TOC entry 3024 (class 0 OID 0)
-- Dependencies: 205
-- Name: trucks_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pguser
--

SELECT pg_catalog.setval('public.trucks_user_id_seq', 2, true);

--
-- TOC entry 2874 (class 2606 OID 16451)
-- Name: location_adjacency location_adjacency_pkey; Type: CONSTRAINT; Schema: public; Owner: pguser
--

ALTER TABLE ONLY public.location_adjacency
    ADD CONSTRAINT location_adjacency_pkey PRIMARY KEY (user_id);


--
-- TOC entry 2870 (class 2606 OID 16443)
-- Name: trucks trucks_name_key; Type: CONSTRAINT; Schema: public; Owner: pguser
--

ALTER TABLE ONLY public.trucks
    ADD CONSTRAINT trucks_name_key UNIQUE (name);
