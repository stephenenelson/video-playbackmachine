--
-- PostgreSQL database dump
--

SET client_encoding = 'SQL_ASCII';
SET check_function_bodies = false;

SET SESSION AUTHORIZATION 'steven';

SET search_path = public, pg_catalog;

--
-- Data for TOC entry 3 (OID 18785)
-- Name: content_types; Type: TABLE DATA; Schema: public; Owner: steven
--

COPY content_types ("type") FROM stdin;
\.


--
-- Data for TOC entry 4 (OID 18792)
-- Name: av_files; Type: TABLE DATA; Schema: public; Owner: steven
--

COPY av_files (title) FROM stdin;
Son of Bambi
SignOff
Sign Off
Qetg
Time 015
Nosferatu
\.


--
-- Data for TOC entry 5 (OID 18799)
-- Name: av_file_component; Type: TABLE DATA; Schema: public; Owner: steven
--

COPY av_file_component (file, title, duration, sequence_no) FROM stdin;
/home/steven/movies/fill_son_of_bambi.asf	Son of Bambi	00:01:50	0
/usr/share/playback_machine/sign_off.avi	SignOff	00:00:20	0
/home/steven/movies/sign_off.avi	Sign Off	00:00:20	0
/home/steven/Video/PlaybackMachine/test_movies/short_QETG.mov	Qetg	00:04:45	0
/home/steven/Video/PlaybackMachine/test_movies/time_015.avi	Time 015	00:00:15	0
/home/steven/movies/movie_nosferatu.avi	Nosferatu	01:24:20	0
\.


--
-- Data for TOC entry 6 (OID 18811)
-- Name: fill_shorts; Type: TABLE DATA; Schema: public; Owner: steven
--

COPY fill_shorts (title, group_name) FROM stdin;
Son of Bambi	\N
Time 015	\N
\.


--
-- Data for TOC entry 7 (OID 18820)
-- Name: contents; Type: TABLE DATA; Schema: public; Owner: steven
--

COPY contents (title, "type", director, description) FROM stdin;
SignOff	\N	\N	\N
Sign Off	\N	\N	\N
Qetg	\N	\N	\N
Nosferatu	\N	\N	\N
\.


--
-- Data for TOC entry 8 (OID 18831)
-- Name: schedules; Type: TABLE DATA; Schema: public; Owner: steven
--

COPY schedules (name) FROM stdin;
Baycon 2005
\.


--
-- Data for TOC entry 9 (OID 18840)
-- Name: content_schedule; Type: TABLE DATA; Schema: public; Owner: steven
--

COPY content_schedule (id, title, schedule, listed, start_time) FROM stdin;
11	Nosferatu	Baycon 2005	t	2005-02-22 18:31:00-08
15	Qetg	Baycon 2005	t	2005-02-22 18:24:00-08
\.


--
-- TOC entry 2 (OID 18838)
-- Name: schedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: steven
--

SELECT pg_catalog.setval('schedule_id_seq', 15, true);


