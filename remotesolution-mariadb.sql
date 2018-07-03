USE thingspin;
/*====================================================================*/
/* Remote Solution 필수 Table 생성 */
/*====================================================================*/
/*--------------------------------------------------------------------*/
-- 상위(ThingSPIN)에서 내려 주는 데이터
/*--------------------------------------------------------------------*/
-- 제품 모델 Table
CREATE TABLE if not exists t_model (
	MODEL_ID 	varchar(32)		NOT NULL PRIMARY KEY,
	DESCRIPTION	nvarchar(128)	NOT NULL,

	REGDATE 	TIMESTAMP		DEFAULT CURRENT_TIMESTAMP
);
-- 검사 및 불량 종류
CREATE TABLE if not exists t_inspection_class (
	IDX			SMALLINT		NOT NULL PRIMARY KEY,
	NAME		nvarchar(128)	NOT NULL,

	REGDATE 	TIMESTAMP		DEFAULT CURRENT_TIMESTAMP
);
insert into t_inspection_class (IDX, NAME) values (1, "검사항목") ON DUPLICATE KEY UPDATE NAME="검사항목";
insert into t_inspection_class (IDX, NAME) values (2, "불량항목") ON DUPLICATE KEY UPDATE NAME="불량항목";
-- 지사 Table
CREATE TABLE if not exists t_plant (
	PLANT_ID 	varchar(32)		NOT NULL PRIMARY KEY,
	DESCRIPTION	nvarchar(128)	NOT NULL
);
insert into t_plant values ('1000', '한국')  ON DUPLICATE KEY UPDATE PLANT_ID='1000';
-- 생산계획 Table
CREATE TABLE t_product_plan
(
	PLAN_DATE		date			NOT NULL,
    PLANT_ID  		varchar(32)	    NOT NULL,
    MODEL_ID     	varchar(32)     NOT NULL, 
    AMOUNT   	  	INT           	NOT NULL,
    PRIMARY KEY (PLAN_DATE, PLANT_ID, MODEL_ID),
    FOREIGN KEY (PLANT_ID) REFERENCES t_plant(PLANT_ID) ON DELETE RESTRICT ON UPDATE RESTRICT,
  	FOREIGN KEY (MODEL_ID) REFERENCES t_model(MODEL_ID) ON DELETE RESTRICT ON UPDATE RESTRICT
);
-- 검사 항목 Table
CREATE TABLE if not exists t_inspection_property (
	IDX	SMALLINT		AUTO_INCREMENT NOT NULL PRIMARY KEY,
	NAME						NVARCHAR(64)	NOT NULL,
	IP_TYPE						SMALLINT		NOT NULL DEFAULT 1,
	
	DEFAULT_MIN					FLOAT			NULL,
	DEFAULT_MAX					FLOAT			NULL,
	DEFAULT_CPK_MIN				FLOAT			NULL,
	DEFAULT_CPK_MAX				FLOAT			NULL,

	DESCRIPTION					nvarchar(128)	NULL,
	REGDATE 					TIMESTAMP		DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY(IP_TYPE)	REFERENCES t_inspection_class(IDX)
);
/* IDX 강제 할당 안됨 */
insert into t_inspection_property (IDX, NAME, IP_TYPE, DEFAULT_MIN, DEFAULT_MAX, DEFAULT_CPK_MIN, DEFAULT_CPK_MAX) values (0,'ALL',1,0,0,0,0)  ON DUPLICATE KEY UPDATE NAME='ALL';
-- 모델별 조치기준
CREATE TABLE if not exists t_model_inspection_property (
	INSPECTION_PROPERTY_INDEX	SMALLINT		NOT NULl,
	ALARM_CONTINUOUS_FAILED_MAX	decimal(2,0)	NULL,
	ALARM_CPK_MIN				FLOAT			NULL,
	ALARM_CPK_MAX				FLOAT			NULL,
	
	PRIMARY KEY(INSPECTION_PROPERTY_INDEX),
	FOREIGN KEY(INSPECTION_PROPERTY_INDEX)	REFERENCES t_inspection_property(IDX)
);
-- 감지 조건 Table
CREATE TABLE if not exists t_perception_condition (
	IDX			SMALLINT		NOT NULL PRIMARY KEY,
	NAME		NVARCHAR(64)	NOT NULL,

	DESCRIPTION	nvarchar(128)	NULL,
	REGDATE 	TIMESTAMP		DEFAULT CURRENT_TIMESTAMP
);
insert into t_perception_condition (IDX, NAME, DESCRIPTION) values (1, "연속불량", "지정한 횟수만큼 불량을 체크") ON DUPLICATE KEY UPDATE NAME="연속불량";
insert into t_perception_condition (IDX, NAME, DESCRIPTION) values (2, "CPK", "지정한 범위의 값을 체크") ON DUPLICATE KEY UPDATE NAME="CPK";

-- 조치 Table
CREATE TABLE if not exists t_action (
	NAME			NVARCHAR(64)	NOT NULL PRIMARY KEY,

	DESCRIPTION		nvarchar(128)	NULL,
	REGDATE 		TIMESTAMP		DEFAULT CURRENT_TIMESTAMP
);
insert into t_action (NAME, DESCRIPTION) values ("None", "안함") ON DUPLICATE KEY UPDATE DESCRIPTION="안함";
insert into t_action (NAME, DESCRIPTION) values ("Alarm", "알람") ON DUPLICATE KEY UPDATE DESCRIPTION="알람";
insert into t_action (NAME, DESCRIPTION) values ("Line Stop", "라인정지") ON DUPLICATE KEY UPDATE DESCRIPTION="라인정지";

-- 검사 종류 Table
Create Table if not exists t_inspection_type (
	IDX				SMALLINT		NOT NULL PRIMARY KEY,
	NAME			NVARCHAR(64)	NOT NULL,
	DESCRIPTION		nvarchar(128)	NULL,
	REGDATE 		TIMESTAMP		DEFAULT CURRENT_TIMESTAMP
);
insert into t_inspection_type (IDX, NAME) values (1, "PBA검사") ON DUPLICATE KEY UPDATE NAME="PBA검사";
insert into t_inspection_type (IDX, NAME) values (2, "기능검사") ON DUPLICATE KEY UPDATE NAME="기능검사";
insert into t_inspection_type (IDX, NAME) values (3, "외관검사") ON DUPLICATE KEY UPDATE NAME="외관검사";
insert into t_inspection_type (IDX, NAME) values (4, "공정검사") ON DUPLICATE KEY UPDATE NAME="공정검사";


-- 사전 조치 Table
CREATE TABLE if not exists t_action_in_advance (
	ID 					int 		AUTO_INCREMENT NOT NULL PRIMARY KEY,
	IP_IDX				SMALLINT	NOT NULL,
	IT_IDX				SMALLINT	NOT NULL,
	
	JSON_DATA			JSON		NOT NULL,
	
	DESCRIPTION			TEXT		NULL,
	REGDATE 			TIMESTAMP	DEFAULT CURRENT_TIMESTAMP,

	FOREIGN KEY(IP_IDX)	REFERENCES t_inspection_property(IDX),
	FOREIGN KEY(IT_IDX)	REFERENCES t_inspection_type(IDX)
);
-- 금형 리스트
CREATE TABLE t_mold
(
	MOLD_ID	int	AUTO_INCREMENT 	NOT NULL,
	REMOTE_MODEL NVARCHAR(100) 	NOT NULL,
	CHANGE_PERIOD	INT			NULL,
	USE_COUNT		INT			NULL,
	BUSINESS_NAME	NVARCHAR(100)	NULL,
	MEMO			NVARCHAR(1000)	NULL,
	UPDATE_DATE	TIMESTAMP		DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (MOLD_ID, REMOTE_MODEL)
);
-- 금형 샘플 insert
insert into t_mold (PLANT_ID, REMOTE_MODEL, CHANGE_PERIOD, USE_COUNT, BUSINESS_NAME, MEMO) values ('1000', 'SC32442B-43', 50000, 30000, '한컴mds', '홍길동 010-1111-2222');
insert into t_mold (PLANT_ID, REMOTE_MODEL, CHANGE_PERIOD, USE_COUNT, BUSINESS_NAME, MEMO) values ('1000', 'SC32442B-43', 100000, 20000, '한컴mds', '김철수 010-2222-3333');
insert into t_mold (PLANT_ID, REMOTE_MODEL, CHANGE_PERIOD, USE_COUNT, BUSINESS_NAME, MEMO) values ('1000', 'SC32442B-43', 40000, 3000, '한컴mds', '이영희 010-4444-5555');
insert into t_mold (PLANT_ID, REMOTE_MODEL, CHANGE_PERIOD, USE_COUNT, BUSINESS_NAME, MEMO) values ('1000', 'SC32442B-43', 20000, 10000, '한컴mds', '장첸 010-5555-6666');
insert into t_mold (PLANT_ID, REMOTE_MODEL, CHANGE_PERIOD, USE_COUNT, BUSINESS_NAME, MEMO) values ('1000', 'SC32442B-43', 60000, 50000, '한컴mds', '조인성 010-6666-7777');

-- -- 업체 리스트
-- CREATE TABLE t_business
-- (
-- 	PLANT_ID 	varchar(32)			NOT NULL,
-- 	BUSINESS_ID	int	AUTO_INCREMENT 	NOT NULL,
-- 	BUSINESS_TYPE	NVARCHAR(20)	NOT NULL,
-- 	NAME	NVARCHAR(100)		NOT NULL,
-- 	PHONE	NVARCHAR(20)		NOT NULL,
-- 	PERSON	NVARCHAR(20)		NOT NULL,
-- 	MAIL	NVARCHAR(100)		NULL,
-- 	MEMO		NVARCHAR(1000)		NULL,
-- 	UPDATE_DATE	TIMESTAMP		DEFAULT CURRENT_TIMESTAMP,
-- 	PRIMARY KEY (BUSINESS_ID, PERSON),
-- 	FOREIGN KEY (PLANT_ID) REFERENCES t_plant(PLANT_ID) ON DELETE RESTRICT ON UPDATE RESTRICT
-- );
-- -- 업체 샘플 insert
-- insert into t_business (PLANT_ID, BUSINESS_TYPE, NAME, PHONE, PERSON, MAIL, MEMO) values ('1000', '장비업체', '한컴mds', '010-1234-1234','박지웅','jiwoong@hancommds.com','');
-- insert into t_business (PLANT_ID, BUSINESS_TYPE, NAME, PHONE, PERSON, MAIL, MEMO) values ('1000', '소모품업체', '한컴mds', '010-1234-1234','김상수','sangsoo.kim@hancommds.com','');
-- insert into t_business (PLANT_ID, BUSINESS_TYPE, NAME, PHONE, PERSON, MAIL, MEMO) values ('1000', '장비업체', '한컴mds', '010-1234-1234','조건우','gunwoo@hancommds.com','');
-- insert into t_business (PLANT_ID, BUSINESS_TYPE, NAME, PHONE, PERSON, MAIL, MEMO) values ('1000', '소모품업체', '한컴mds', '010-1234-1234','이주용','jooyong@hancommds.com','');
-- insert into t_business (PLANT_ID, BUSINESS_TYPE, NAME, PHONE, PERSON, MAIL, MEMO) values ('1000', '금형업체', '한컴mds', '010-1234-1234','조다슬','daseul@hancommds.com','');
-- insert into t_business (PLANT_ID, BUSINESS_TYPE, NAME, PHONE, PERSON, MAIL, MEMO) values ('1000', '소모품업체', '한컴mds', '010-1234-1234','이은혜','eunhye.lee@hancommds.com','');
-- insert into t_business (PLANT_ID, BUSINESS_TYPE, NAME, PHONE, PERSON, MAIL, MEMO) values ('1000', '소모품업체', '한컴mds', '010-1234-1234','심봉기','	pongki@hancommds.com','');

-- 장비 리스트
-- CREATE TABLE t_machine
-- (
-- 	PLANT_ID 	varchar(32)			NOT NULL,
-- 	MACHINE_ID	NVARCHAR(20)		NOT NULL,
-- 	MACHINE_NAME NVARCHAR(100)		NOT NULL,
-- 	BUSINESS_ID	int	 NOT NULL,
-- 	MEMO		NVARCHAR(1000)		NULL,
-- 	UPDATE_DATE	TIMESTAMP		DEFAULT CURRENT_TIMESTAMP,
-- 	PRIMARY KEY (MACHINE_ID),
-- 	FOREIGN KEY (PLANT_ID) REFERENCES t_plant(PLANT_ID) ON DELETE RESTRICT ON UPDATE RESTRICT,
-- 	FOREIGN KEY (BUSINESS_ID) REFERENCES t_business(BUSINESS_ID) ON DELETE RESTRICT ON UPDATE RESTRICT
-- );
-- -- 장비 샘플 insert
-- insert into t_machine (PLANT_ID, MACHINE_ID, MACHINE_NAME, BUSINESS_ID) values ('1000', 'front', '사출기', 2);
-- insert into t_machine (PLANT_ID, MACHINE_ID, MACHINE_NAME, BUSINESS_ID) values ('1000', 'convey', '컨베이어', 3);
-- insert into t_machine (PLANT_ID, MACHINE_ID, MACHINE_NAME, BUSINESS_ID) values ('1000', 'print', '인쇄기', 2);
-- insert into t_machine (PLANT_ID, MACHINE_ID, MACHINE_NAME, BUSINESS_ID) values ('1000', 'shunt', '분류기', 3);
-- insert into t_machine (PLANT_ID, MACHINE_ID, MACHINE_NAME, BUSINESS_ID) values ('1000', 'inspection', '검사장비', 2);

-- 소모품 리스트
CREATE TABLE t_consumables
(
	CONSUMABLES_ID	int	AUTO_INCREMENT NOT NULL,
	CONSUMABLES_NAME NVARCHAR(100)		NOT NULL,
	CONSUMABLES_STANDARD	NVARCHAR(500)	NOT NULL,
	SAFE_COUNT	int NOT NULL,
	CURRENT_COUNT	int	NOT NULL,	
	CHANGE_RATE	int NOT NULL,
	BUSINESS_NAME	NVARCHAR(100) NULL,
	MEMO		NVARCHAR(1000)		NULL,
	UPDATE_DATE	TIMESTAMP		DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (CONSUMABLES_ID)
);
-- 소모품 샘플 insert
insert into t_consumables (CONSUMABLES_NAME, CONSUMABLES_STANDARD, SAFE_COUNT, CURRENT_COUNT, CHANGE_RATE, BUSINESS_NAME, MEMO) values ('실린더', 'SMC40-20', 1000, 10000, 500, '한컴MDS', '이수근 010-8888-9999');
insert into t_consumables (CONSUMABLES_NAME, CONSUMABLES_STANDARD, SAFE_COUNT, CURRENT_COUNT, CHANGE_RATE, BUSINESS_NAME, MEMO) values ('리노핀', 'TCEM-3T', 1000, 10000, 500, '한컴MDS', '강호동 010-8000-9000');
insert into t_consumables (CONSUMABLES_NAME, CONSUMABLES_STANDARD, SAFE_COUNT, CURRENT_COUNT, CHANGE_RATE, BUSINESS_NAME, MEMO) values ('리노핀', 'TCEM-1T', 1000, 10000, 500, '한컴MDS', '김범수 010-1000-2000');
insert into t_consumables (CONSUMABLES_NAME, CONSUMABLES_STANDARD, SAFE_COUNT, CURRENT_COUNT, CHANGE_RATE, BUSINESS_NAME, MEMO) values ('솔레로이드밸브', 'TPC24-10', 1000, 10000, 500, '한컴MDS', '정우성 010-2020-3030');
insert into t_consumables (CONSUMABLES_NAME, CONSUMABLES_STANDARD, SAFE_COUNT, CURRENT_COUNT, CHANGE_RATE, BUSINESS_NAME, MEMO) values ('센서', 'SC30-1', 1000, 10000, 500, '한컴MDS', '장동건 010-5555-4040');
insert into t_consumables (CONSUMABLES_NAME, CONSUMABLES_STANDARD, SAFE_COUNT, CURRENT_COUNT, CHANGE_RATE, BUSINESS_NAME, MEMO) values ('모터', 'MO220V-10', 1000, 10000, 500, '한컴MDS', '원빈 010-6060-0077');

CREATE TABLE t_machine_use 
(
	MACHINEUSE_ID	int AUTO_INCREMENT NOT NULL,
	MACHINE_NAME	NVARCHAR(100)	NOT NULL,
	CONSUMABLES_ID	int NOT NULL,
	MACHINEUSE_COUNT	int NOT NULL,
	BUSINESS_NAME	NVARCHAR(100) NULL,
	MEMO		NVARCHAR(1000)	NULL,
	PRIMARY KEY (MACHINEUSE_ID, CONSUMABLES_ID),
	FOREIGN KEY (CONSUMABLES_ID) REFERENCES t_consumables(CONSUMABLES_ID) ON DELETE RESTRICT ON UPDATE RESTRICT
);

insert into t_machine_use (MACHINE_NAME, CONSUMABLES_ID, MACHINEUSE_COUNT, BUSINESS_NAME, MEMO) values ('검사기1', 1, 200, '한컴MDS', '김승우 010-8888-9999');
insert into t_machine_use (MACHINE_NAME, CONSUMABLES_ID, MACHINEUSE_COUNT, BUSINESS_NAME, MEMO) values ('검사기2', 2, 600, '한컴MDS', '조승우 010-1919-9999');
insert into t_machine_use (MACHINE_NAME, CONSUMABLES_ID, MACHINEUSE_COUNT, BUSINESS_NAME, MEMO) values ('검사기3', 3, 700, '한컴MDS', '제갈승우 010-2020-9999');
insert into t_machine_use (MACHINE_NAME, CONSUMABLES_ID, MACHINEUSE_COUNT, BUSINESS_NAME, MEMO) values ('검사기4', 4, 800, '한컴MDS', '최승우 010-3838-9999');
insert into t_machine_use (MACHINE_NAME, CONSUMABLES_ID, MACHINEUSE_COUNT, BUSINESS_NAME, MEMO) values ('검사기5', 5, 900, '한컴MDS', '박승우 010-4545-9999');


-- 입/출고 리스트
-- CREATE TABLE t_shipper_receiver
-- (
-- 	PLANT_ID 	varchar(32)			NOT NULL,
-- 	OPERATION_DATE	TIMESTAMP		NOT NULL,
-- 	SR_TYPE	BOOLEAN	NOT NULL,
-- 	MACHINE_ID	NVARCHAR(20)		NOT NULL,
-- 	CONSUMABLES_ID	int	 NOT NULL,	
-- 	SR_COUNT	int	NOT NULL,
-- 	MEMO		NVARCHAR(1000)		NULL,
-- 	UPDATE_DATE	TIMESTAMP		DEFAULT CURRENT_TIMESTAMP,
-- 	PRIMARY KEY (OPERATION_DATE),
-- 	FOREIGN KEY (PLANT_ID) REFERENCES t_plant(PLANT_ID) ON DELETE RESTRICT ON UPDATE RESTRICT,
-- 	FOREIGN KEY (MACHINE_ID) REFERENCES t_machine(MACHINE_ID) ON DELETE RESTRICT ON UPDATE RESTRICT,
-- 	FOREIGN KEY (CONSUMABLES_ID) REFERENCES t_consumables(CONSUMABLES_ID) ON DELETE RESTRICT ON UPDATE RESTRICT
-- );

-- 모델 스펙
CREATE TABLE if not exists t_model_spec
(
	ID 		varchar(32)	NOT NULL PRIMARY KEY,

	IP_JSON			JSON		NOT NULL,
	
	DESCRIPTION		TEXT		NULL,
	REGDATE 		TIMESTAMP	DEFAULT CURRENT_TIMESTAMP,

	FOREIGN KEY(ID)	REFERENCES t_model(MODEL_ID)
);
/*====================================================================*/
/* Remote Solution ThingSPIN 관리 Table 생성 */
/*====================================================================*/
CREATE TABLE if not exists t_ws_log (
	WS_ID 		int 		AUTO_INCREMENT NOT NULL PRIMARY KEY,
	WS_TYPE 	varchar(4)	NOT NULL, /* 송신 or 수신 */
	REGDATE 	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP,

	SRC			varchar(20)	NOT NULL,
	DEST		varchar(20)	NOT NULL,
	CONTENTS	TEXT		NOT NULL,

	PASS		BOOLEAN		NOT NULL,
	ERROR		TEXT		NULL
);
-- UPDATE 
CREATE TABLE if not exists t_ws_login (
	WS_ID 			int 		AUTO_INCREMENT NOT NULL PRIMARY KEY,
	siteCode		varchar(20) NOT NULL,
	WS_SESSION_ID 	decimal		NOT NULL, /* 송신 or 수신 */
	REGDATE 		TIMESTAMP	DEFAULT CURRENT_TIMESTAMP,

	CONN			BOOLEAN		NOT NULL
);

CREATE TABLE if not exists t_run_py_proc (
	RUN_SEQUENCE	int 			AUTO_INCREMENT NOT NULL PRIMARY KEY,
	COMMAND			varchar(128)	NOT NULL,	
	PID				varchar(20)		NOT NULL,

	REGDATE 		TIMESTAMP		DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE if not exists t_mqtt_log (
	MSG_ID 		int 		AUTO_INCREMENT NOT NULL PRIMARY KEY,
	REGDATE 	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP,
	CONTENTS	TEXT		NOT NULL
);
/*====================================================================*/
