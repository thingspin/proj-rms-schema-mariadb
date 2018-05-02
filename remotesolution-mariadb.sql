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
insert into t_plant values ('1000', '한국');
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
-- 모델별 조치기준
CREATE TABLE if not exists t_model_inspection_property (
	INSPECTION_PROPERTY_INDEX	SMALLINT		NOT NULl,
	ALARM_CONTINUOUS_FAILED_MAX	decimal(2,0)	NULL,
	ALARM_CPK_MIN				FLOAT			NULL,
	ALARM_CPK_MAX				FLOAT			NULL,
	
	PRIMARY KEY(INSPECTION_PROPERTY_INDEX),
	FOREIGN KEY(INSPECTION_PROPERTY_INDEX)	REFERENCES t_inspection_property(IDX)
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
