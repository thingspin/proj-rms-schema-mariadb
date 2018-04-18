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
	DESCRIPTION	nvarchar(128)	NOT NULL
);
-- 검사 항목 Table
CREATE TABLE if not exists t_inspection_property (
	INSPECTION_PROPERTY_INDEX	SMALLINT		NOT NULL PRIMARY KEY,
	INSPECTION_PROPERTY_NAME	NVARCHAR(64)	NOT NULL,
	DESCRIPTION	nvarchar(128)	NOT NULL
);
-- 모델별 조치기준
CREATE TABLE if not exists t_model_inspection_property (
	MODEL_ID 					varchar(32)		NOT NULL,
	INSPECTION_PROPERTY_INDEX	SMALLINT		NOT NULl,
	ALARM_CONTINUOUS_FAILED_MAX	decimal(2,0)	NULL,
	ALARM_CPK_MIN				FLOAT			NULL,
	ALARM_CPK_MAX				FLOAT			NULL,
	
	PRIMARY KEY(MODEL_ID, INSPECTION_PROPERTY_INDEX),
	FOREIGN KEY(MODEL_ID) 					REFERENCES t_model(MODEL_ID),
	FOREIGN KEY(INSPECTION_PROPERTY_INDEX)	REFERENCES t_inspection_property(INSPECTION_PROPERTY_INDEX)
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
/*====================================================================*/
