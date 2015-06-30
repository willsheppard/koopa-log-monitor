--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: pattern_count; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pattern_count (
    id integer NOT NULL,
    date date,
    environment character varying(100),
    file character varying(100),
    pattern character varying(100),
    count integer
);


ALTER TABLE public.pattern_count OWNER TO postgres;

--
-- Name: pattern_count_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pattern_count_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.pattern_count_id_seq OWNER TO postgres;

--
-- Name: pattern_count_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pattern_count_id_seq OWNED BY pattern_count.id;


--
-- Name: pattern_count_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('pattern_count_id_seq', 19592, true);


--
-- Name: pattern_count_test; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pattern_count_test (
    id integer NOT NULL,
    date date,
    environment character varying(100),
    file character varying(100),
    pattern character varying(100),
    count integer
);


ALTER TABLE public.pattern_count_test OWNER TO postgres;

--
-- Name: pattern_count_test_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pattern_count_test_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.pattern_count_test_id_seq OWNER TO postgres;

--
-- Name: pattern_count_test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pattern_count_test_id_seq OWNED BY pattern_count_test.id;


--
-- Name: pattern_count_test_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('pattern_count_test_id_seq', 336, true);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE pattern_count ALTER COLUMN id SET DEFAULT nextval('pattern_count_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE pattern_count_test ALTER COLUMN id SET DEFAULT nextval('pattern_count_test_id_seq'::regclass);


--
-- Data for Name: pattern_count; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pattern_count (id, date, environment, file, pattern, count) FROM stdin;
13881	2013-06-06	live	full_app2	log4perl_error	\N
13882	2013-06-06	live	full_app2	log4perl_warn	\N
13883	2013-06-06	test	doc_mcstuffin	uninit	\N
13884	2013-06-06	test	fandango	uninit	\N
13885	2013-06-06	test	debt_collector	uninit	\N
13886	2013-06-06	test	app2	uninit	\N
13887	2013-06-06	test	rain_collector	uninit	\N
13888	2013-06-06	test	wikkipuds	uninit	\N
13889	2013-06-06	test	app1_env_units_dc1	uninit	\N
13890	2013-06-06	test	app1_env_units_dc2	uninit	\N
13891	2013-06-06	test	app1_env_units_dc3	uninit	\N
13892	2013-06-06	test	app1_orders_dc1	uninit	\N
13893	2013-06-06	test	app1_orders_dc2	uninit	\N
13894	2013-06-06	test	app1_orders_dc3	uninit	\N
13895	2013-06-06	test	app1_other_dc1	uninit	\N
13896	2013-06-06	test	app1_other_dc2	uninit	\N
13897	2013-06-06	test	app1_other_dc3	uninit	\N
13898	2013-06-06	live	app1_dc1	uninit	\N
13899	2013-06-06	live	app1_dc2	uninit	\N
13900	2013-06-06	live	full_app2	uninit	\N
\.


--
-- Data for Name: pattern_count_test; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pattern_count_test (id, date, environment, file, pattern, count) FROM stdin;
\.


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

