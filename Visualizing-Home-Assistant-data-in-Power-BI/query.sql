DROP FUNCTION IF EXISTS `IsNumeric`;
DROP VIEW IF EXISTS `states_powerbi`;
DROP VIEW IF EXISTS `entities_powerbi`;

CREATE FUNCTION IsNumeric (sIn varchar(1024)) RETURNS tinyint
RETURN sIn REGEXP '^(-|\\+){0,1}([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)$';

CREATE VIEW states_powerbi as
select
	a.state_id
    ,a.entity_id
    ,a.state
    ,a.attributes
    ,JSON_EXTRACT(a.attributes, '$.unit_of_measurement') as unit_of_measurement
    ,a.last_changed
    ,a.last_updated
    ,a.created
    ,CASE WHEN a.isnumeric = 1 THEN a.state_numeric else NULL END as state_numeric
from (
    select
        state_id,
        entity_id,
        state,
        attributes,
        last_changed,
        last_updated,
        created,
        IsNumeric(state) as isnumeric,
        CAST(state as float) as state_numeric
    from states
) a;

CREATE VIEW entities_powerbi as
SELECT distinct entity_id, domain FROM states;