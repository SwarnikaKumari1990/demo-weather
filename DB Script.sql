/*********************************************************
 Script for Config DB and Data Table

**************************************************************/

-- Different schema to serve the different purpose in the sultion
Create Schema config;
Create Schema zones;
Create Schema geodata;
Create Schema datamodel;

--drop table config.etlobject;
create table config.etlobject(
    id int identity,
    objectschema nvarchar(50),
    objectName nvarchar(50),
    baseURL nvarchar(max),
    columnMapping nvarchar(max),
    Lastdataacquired datetime,
    status nvarchar(10),
    remark nvarchar(250)

);

-- Below insert Script will setup the config DB necessary for running the ADF framework
-- Truncate table config.etlobject
INSERT INTO config.etlobject( objectschema,objectName,baseURL,columnMapping,Lastdataacquired, status,remark)
select 'zones','jsonfeed','https://api.weather.gov/zones','{
                        "type": "TabularTranslator",
                        "mappings": [
                            {
                                "source": {
                                    "path": "[''''id'''']"
                                },
                                "sink": {
                                    "name": "id",
                                    "type": "String"
                                }
                            },
                            {
                                "source": {
                                    "path": "[''''type'''']"
                                },
                                "sink": {
                                    "name": "type",
                                    "type": "String"
                                }
                            },
                            {
                                "source": {
                                    "path": "[''''geometry'''']"
                                },
                                "sink": {
                                    "name": "geometry",
                                    "type": "String"
                                }
                            },
                            {
                                "source": {
                                    "path": "[''''properties'''']"
                                },
                                "sink": {
                                    "name": "properties",
                                    "type": "String"
                                }
                            }
                        ],
                        "collectionReference": "$[''features'']",
                        "mapComplexValuesToString": true
                    }','1900-01-01','0','intial load' union
select 'geodata','jsonfeed','https://api.weather.gov/alerts/active','{
                        "type": "TabularTranslator",
                        "mappings": [
                            {
                                "source": {
                                    "path": "[''''id'''']"
                                },
                                "sink": {
                                    "name": "id",
                                    "type": "String"
                                }
                            },
                            {
                                "source": {
                                    "path": "[''''type'''']"
                                },
                                "sink": {
                                    "name": "type",
                                    "type": "String"
                                }
                            },
                            {
                                "source": {
                                    "path": "[''''geometry'''']"
                                },
                                "sink": {
                                    "name": "geometry",
                                    "type": "String"
                                }
                            },
                            {
                                "source": {
                                    "path": "[''''properties'''']"
                                },
                                "sink": {
                                    "name": "properties",
                                    "type": "String"
                                }
                            }
                        ],
                        "collectionReference": "$[''''features'''']",
                        "mapComplexValuesToString": true
                    }','1900-01-01','0','intial load';


select * from config.etlobject;

Create procedure config.get_etlobject AS
BEGIN

    select * from config.etlobject where status IN ('0','1')

END;


-- drop table zones.jsonfeed
create table zones.jsonfeed(
    id nvarchar(max),
    [type] nvarchar(max),
    [geometry] nvarchar(max),
    properties nvarchar(max),
    addedOn datetime default CURRENT_TIMESTAMP
);

-- drop table geodata.jsonfeed
create table geodata.jsonfeed(
    id nvarchar(max),
    [type] nvarchar(max),
    [geometry] nvarchar(max),
    properties nvarchar(max),
    addedOn datetime default CURRENT_TIMESTAMP
);

select * from zones.jsonfeed;
select * from geodata.jsonfeed;

CREATE view datamodel.dim_state AS  
            select distinct jsonValues.Id, jsonValues.[type],[State]
            from zones.jsonfeed 
            CROSS APPLY OPENJSON(properties)
            WITH (
                                [Id] VARCHAR(250) '$.id',

                                [type] VARCHAR(1000) '$.type',
                                [name] VARCHAR(1000) '$.name',
                                effectiveDate DATETIME2 '$.effectiveDate',
                                expirationDate DATETIME2 '$.expirationDate',
                                cwa nVARCHAR(max) '$.cwa' as json ,
                                [state] nVARCHAR(max) '$.state' as json ,
                                timeZone VARCHAR(100) '$.timeZone'
                        ) AS jsonValues ;



Create view datamodel.geodata AS  
            select jsonValues.[Id] ,areaDesc,affectedZones,[sent] ,effective ,expires ,[references] ,[status] ,[messageType] ,[category] ,[certainty] ,[event] ,[sender] 
            from geodata.jsonfeed 
            CROSS APPLY OPENJSON(properties)
            WITH (
                                [Id] VARCHAR(250) '$.id',

                                [areaDesc] VARCHAR(1000) '$.areaDesc',
                                [affectedZones] nVARCHAR(max) '$.affectedZones' As JSON,

                                [sent] DATETIME2 '$.sent',
                                effective DATETIME2 '$.effective',
                                expires datetime2 '$.expires',
                                [references] VARCHAR(1000) '$.references',
                                [status] VARCHAR(1000) '$.status',
                                [messageType] VARCHAR(1000) '$.messageType',
                                [category] VARCHAR(1000) '$.category',
                                [certainty] VARCHAR(1000) '$.certainty',
                                [event] VARCHAR(1000) '$.event',
                                [sender] VARCHAR(1000) '$.sender'
                        ) AS jsonValues ;
