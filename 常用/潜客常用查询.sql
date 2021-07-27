-- 线索池
select
    c.id as id,
    '1' as selectedTab,
    c.mobile_phone as mobilePhone,
    c.origin_platform as originPlatform,
    c.name as name,
    c.clue_type as clueType,
    c.clue_status as clueStatus,
    c.repeat_flag as repeatFlag,
    wechat_head as wechatHead,
    TIMESTAMPDIFF(SECOND, now( ), DATE_FORMAT( DATE_ADD( DATE_FORMAT( c.pc_allocate_time, '%Y-%m-%d' ), INTERVAL c.pc_follow_time DAY ), '%Y-%m-%d %H:%i:%s' ) ) AS clueSpareTime,
    TIMESTAMPDIFF( DAY, now( ), DATE_FORMAT( DATE_ADD( DATE_FORMAT( c.pc_allocate_time, '%Y-%m-%d' ), INTERVAL c.pc_follow_time DAY ), '%Y-%m-%d %H:%i:%s' ) ) AS clueSpareDay
    from tbl_a_clue c
    where c.select_person=11150 and c.delete_flag = '0'
      and c.clue_status in('145002','145007','145008') and c.store_id=1
    and c.pc_follow_time IS NOT NULL AND c.pc_allocate_time IS NOT NULL
    order by c.clue_status,clueSpareTime
-- 待跟进
select * from ((select
        toAccept.id as id,
        toAccept.store_id as storeId,
        toAccept.`name` as name,
        toAccept.sex as sex,
        toAccept.photo_url as photoUrl,
        toAccept.wechat_head as wechatHead,
        toAccept.mobile_phone as mobilePhone,
        toAccept.intention_vehicle as intentionVehicle,
        toAccept.origin_platform as originPlatform,
        toAccept.clue_type as clueType,
        toAccept.clue_status as clueStatus,
        toAccept.follow_status as followStatus,
        toAccept.follow_start_time1 as followStartTime1,
        toAccept.follow_start_time2 as followStartTime2,
        toAccept.enter_datetime as enterDatetime,
        toAccept.belong_person as belongPerson,
        null as followDate,
        null as calendarId,
        0 as days,
        UNIX_TIMESTAMP(date_add(toAccept.dcc_allocate_time, interval '00:06:00' hour_second) ) - UNIX_TIMESTAMP(now())
        as timeLeft,
        (select count(id) from tbl_a_follow taf where taf.potential_id = toAccept.id and taf.follow_type = '148003') callTimes
        from
        tbl_potential_customer toAccept
        where
        toAccept.delete_flag = '0'
        AND toAccept.dcc_allocate_target = 9802
        AND toAccept.store_id = 3
            AND toAccept.clue_status = '145007' -- 待接单
        )
        union all(
				SELECT
        max(t3.id) as id,
        max(t3.store_id) as storeId,
        max(t3.`name`) as name,
        max(t3.sex) as sex,
        max(t3.photo_url) as photoUrl,
        max(t3.wechat_head) as wechatHead,
        max(t3.mobile_phone) as mobilePhone,
        max(t3.intention_vehicle) as intentionVehicle,
        max(t3.origin_platform) as originPlatform,
        max(t3.clue_type) as clueType,
        max(t3.clue_status) as clueStatus,
        max(t3.follow_status) as followStatus,
        max(t3.follow_start_time1) as followStartTime1,
        max(t3.follow_start_time2) as followStartTime2,
        max(t3.enter_datetime) as enterDatetime,
        max(t3.belong_person) as belongPerson,
        min(t3.follow_date) as followDate,
        max(t3.calendar_id) as calendarId,
        max(t3.days),
        min(UNIX_TIMESTAMP(DATE_FORMAT(
        CASE
        WHEN t3.days >= 0 and t3.days < (config.config_content + 0 ) THEN INTERVAL t3.follow_date DAY + DATE(IF (
        t3.clue_status = '145003', t3.follow_start_time1, t3.follow_start_time2 ))
        WHEN t3.days >= (config.config_content + 0 ) THEN t3.continue_follow_date
        ELSE INTERVAL t3.follow_date DAY + DATE(IF ( t3.clue_status = '145003', t3.follow_start_time1,
        t3.follow_start_time2 )) END,
        '%Y-%m-%d %H:%i:%s')) - UNIX_TIMESTAMP(NOW())) AS timeLeft,
        (select count(id) from tbl_a_follow taf where taf.potential_id = t3.id and taf.follow_type = '148003') callTimes
        FROM
        (SELECT
        @i:=@i + 1 rownum,
        IF(@temp = t1.name, @rank:=@rank + 1, @rank:=1) AS rank,
        @temp:=t1.name,
        t1.*
        FROM
        (SELECT @i:=0, @temp:='', @rank:=0) t2, (SELECT
        tpc.id,
        tpc.store_id,
        tpc.`name`,
        tpc.sex,
        tpc.photo_url,
        tpc.wechat_head,
        tpc.mobile_phone,
        tpc.intention_vehicle,
        tpc.origin_platform,
        tpc.clue_type,
        tpc.clue_status,
        tpc.follow_status,
        tpc.follow_start_time1,
        tpc.follow_start_time2,
        tpc.enter_datetime,
        tpc.belong_person,
        tpc.continue_follow_date,
        tafcd.follow_date,
        tafcd.calendar_id,
        TO_DAYS(NOW()) - TO_DAYS(IF(tpc.clue_status = '145003', tpc.follow_start_time1, tpc.follow_start_time2)) AS days
        FROM
        tbl_potential_customer tpc
        LEFT JOIN tbl_a_follow_calendar tafc ON tpc.store_id = tafc.store_id
        AND IF(tpc.clue_status = '145003', tafc.period = '153001', tafc.period = '153002')
        LEFT JOIN tbl_a_follow_calendar_detial tafcd ON tafc.id = tafcd.calendar_id
        WHERE tpc.delete_flag = '0'
        AND tpc.belong_person = 9802
        AND tpc.store_id = 3
        AND tpc.clue_status IN('145003','145004','145009') AND tpc.follow_status = '146001'
            ORDER BY tpc.id , tafcd.follow_date
        ) t1) t3
        left join tbl_config_set config on config.store_id = t3.store_id and if(t3.clue_status =
        '145003','164001','165001') = config.config_code
        WHERE
            t3.clue_status = '145009' or
        IF((select MAX(t4.follow_date) from tbl_a_follow_calendar_detial t4 where t4.calendar_id = t3.calendar_id) <=
        t3.days,
        t3.follow_date = (SELECT
        MAX(follow_date)
        FROM
        tbl_a_follow_calendar_detial
        WHERE
        calendar_id = t3.calendar_id),
        t3.days < t3.follow_date)
        group by t3.id)) customers order by customers.timeLeft,callTimes,customers.id	
-- 判断是否有重复同步的账号
select t1.* from tbl_employee t1 LEFT JOIN tbl_employee t2 on t1.id != t2.id and t1.dop_name = t2.dop_name and t1.mobile_phone = t2.mobile_phone
where  t1.store_id = 491 and  t2.store_id = 491

--展厅排班
SELECT e.id AS id,
		e.dop_name AS dopName,
		e.store_id AS storeId,
		e.avatar_url AS avatarUrl,
		e.photo_url AS photoUrl,
		s.employee_id AS employeeId,
		s.exhibition_schedule_status AS exhibitionScheduleStatus,
		s.exhibition_reception_status AS exhibitionReceptionStatus,
		s.exhibition_eception_duration AS exhibitionEceptionDuration,
		s.dcc_schedule_status AS dccScheduleStatus,
		s.update_time AS updateTime
		FROM tbl_employee_schedule s
		LEFT JOIN tbl_employee e
		ON e.id = s.employee_id
		WHERE e.store_id =491
		AND e.delete_flag=0
		AND s.delete_flag=0
		AND s.store_id = 491
		AND s.exhibition_reception_status ='116002'
			AND s.exhibition_schedule_status='115001'