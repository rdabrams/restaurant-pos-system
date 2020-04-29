use pizzaposdb;
Delimiter $$
CREATE FUNCTION `pizzaposdb`.`successValue` ()
RETURNS INTEGER DETERMINISTIC
BEGIN
	RETURN 1;
END$$
drop procedure if exists pizzaposdb.create_Menu$$
create procedure create_Menu 
(
	IN p_StoreID varchar(50),
    IN p_MenuName varchar(50),
    IN p_MenuType varchar(50),
	IN p_UUID varchar(36),
	IN p_IsActive varchar(50),
    IN p_SortValue varchar(50),
    OUT retID int
)
BEGIN
	declare StoreID int;
    declare MenuName varchar(50);
    declare MenuType int;
	declare UUID varchar(36);
	declare IsActive int;
    declare SortValue int;
    set StoreID = cast(p_StoreID as unsigned);
    set MenuName = p_MenuName;
    set MenuType = cast(p_MenuType as unsigned);
    set UUID = p_UUID;
    set IsActive = cast(p_IsActive as unsigned);
    set SortValue = cast(p_SortValue as unsigned);
    
	INSERT INTO `pizzaposdb`.`Menu`
    (
		`UUID`,
        `SortValue`,
        `IsActive`,
        `StoreID`,
        `MenuType`,
        `MenuName`
	) VALUES
    (
		UUID,
        SortValue, 
        IsActive,
        StoreID, 
        MenuType,
        MenuName
	);
	set retID = last_insert_id();
END$$

drop procedure if exists read_Menu$$
create procedure read_Menu
(
    in p_IsActive varchar(50),
    in p_StoreID varchar(50)
)
BEGIN
	declare IsActive int;
    declare StoreID int;
    set IsActive = p_IsActive;
    set StoreID = p_StoreID;
    
	select * from `pizzaposdb`.`Menu`
    WHERE `Menu`.`IsActive` = IsActive and
		`Menu`.`StoreID` = StoreID;
END$$

drop procedure if exists update_Menu$$
create procedure update_Menu
(
	IN p_StoreID varchar(50),
    IN p_MenuName varchar(50),
    IN p_MenuType varchar(50),
	IN p_ID varchar(50),
    IN p_UUID varchar(36),
	IN p_IsActive varchar(50),
    IN p_SortValue varchar(50),
    OUT retVal int
)
BEGIN
	declare StoreID int;
    declare MenuName varchar(50);
    declare MenuType int;
	declare ID int;
    declare UUID varchar(36);
	declare IsActive int;
    declare SortValue int;
	UPDATE `pizzaposdb`.`Menu` SET
		`SortValue` = SortValue,
		`IsActive` = IsActive,
		`StoreID` = StoreID,
		`MenuType` = MenuType,
		`MenuName` = MenuName
	WHERE `UUID` = UUID and `ID` = ID;
	set retVal = successValue();
END$$

drop procedure if exists delete_Menu$$
create procedure delete_Menu
(
	in ID int,
    in UUID int,
    in IsActive bit,
    OUT retVal int
)
BEGIN
	UPDATE `pizzaposdb``Menu` SET
		`IsActive` = IsActive
	where `UUID` = UUID and `ID` = ID;
    SET retVal = successValue();
END$$

drop procedure if exists create_MenuItem$$
create procedure create_MenuItem
(
	IN p_ItemName varchar(64),
    IN p_MenuID varchar(64),
    IN p_Price varchar(64),
    IN p_PriorityScore varchar(64),
    IN p_ExecutionTime varchar(64),
    IN p_UUID varchar(64),
	IN p_IsActive varchar(64),
    IN p_SortValue varchar(64),
    OUT ID int
)
BEGIN
	declare ItemName varchar(64);
    declare MenuID int;
    declare Price double;
    declare PriorityScore int;
    declare ExecutionTime int;
    declare UUID varchar(36);
	declare IsActive int;
    declare SortValue int;
    set ItemName = p_ItemName;
    set MenuID = cast(p_MenuID as unsigned);
    set Price = cast(p_Price as decimal(10,2));
    set PriorityScore = cast(p_PriorityScore as unsigned);
    set ExecutionTime = cast(p_ExecutionTime as unsigned);
    set UUID = p_UUID;
	set IsActive = cast(p_IsActive as binary);
    set SortValue = cast(p_SortValue as unsigned);
	INSERT INTO `pizzaposdb`.`MenuItem`
    (
		`UUID`,
        `SortValue`,
        `IsActive`,
        `MenuID`,
        `ItemName`,
        `Price`,
        `PriorityScore`,
        `ExecutionTime`
	) VALUES
    (
		UUID,
        SortValue, 
        IsActive,
        MenuID,
		ItemName,
		Price,
		PriorityScore,
		ExecutionTime
	);
    set ID = last_insert_id();
	-- set ID = (SELECT `MenuItem`.`ID` FROM `pizzaposdb`.`MenuItem` where
-- 		`UUID` = UUID and
-- 		`SortValue` = SortValue and
-- 		`IsActive` = IsActive and
-- 		`MenuID` = MenuID and
--         `ItemName` = ItemName and
--         `Price` = Price and
--         `PriorityScore` = PriorityScore and
--         `ExecutionTime` = ExecutionTime);
	-- select ID;
END$$

drop procedure if exists read_MenuItem$$
create procedure read_MenuItem
(
	in MenuID int,
    in IsActive int
)
BEGIN
	select * from `pizzaposdb`.`MenuItem`
    WHERE `MenuItem`.`IsActive` = IsActive and
		`Menu`.`MenuID` = MenuID;
END$$

drop procedure if exists update_MenuItem$$
create procedure update_MenuItem
(
	IN ItemName varchar(64),
    IN MenuID int,
    IN Price double,
    IN PriorityScore int,
    IN ExecutionTime int,
	IN ID int,
    IN UUID varchar(36),
	IN IsActive bit,
    IN SortValue int,
    OUT retVal int
)
BEGIN
	UPDATE `pizzaposdb`.`MenuItem` SET
		`SortValue` = SortValue,
		`IsActive` = IsActive,
		`MenuID` = MenuID,
		`ItemName` = ItemName,
		`Price` = MenuName
	WHERE `UUID` = UUID and `ID` = ID;
	set retVal = successValue();
END$$

drop procedure if exists delete_MenuItem$$
create procedure delete_MenuItem
(
	in ID int,
    in UUID int,
    in IsActive bit,
    OUT retVal int
)
BEGIN
	UPDATE `pizzaposdb``MenuItem` SET
		`IsActive` = IsActive
	where `UUID` = UUID and `ID` = ID;
    SET retVal = successValue();
END$$

drop procedure if exists create_PosCheck$$
create procedure create_PosCheck
(
	IN TableID int,
    IN UserID int,
    IN CheckStatus int,
    IN DateStarted datetime,
    IN DateClosed datetime,
	IN UUID varchar(36),
    IN IsActive bit,
    IN SortValue int,
    OUT ID int
)
BEGIN
	INSERT INTO `pizzaposdb`.`poscheck`
	(
		`UUID`,
        `IsActive`,
        `SortValue`,
		`TableID`,
		`UserID`,
		`CheckStatus`,
		`DateStarted`,
		`DateClosed`
	) VALUES
	(
		UUID,
        SortValue,
        IsActive,
        TableID,
        UserID,
        CheckStatus,
        DateStarted,
        DateClosed
    );
	set ID = (SELECT `poscheck`.`ID` FROM `pizzaposdb`.`poscheck`
		where `UUID` = UUID and
		`SortValue` = SortValue and
        `IsActive` = IsActive and
		`TableID` = TableID and
		`UserID` = UserID and
		`CheckStatus` = CheckStatus and
		`DateStarted` = DateStarted and
		`DateClosed` = DateClosed);
END$$

drop procedure if exists read_PosCheck$$
create procedure read_PosCheck
(
	IN IsActive int,
    IN TableID int,
    IN UserID int,
    IN CheckStatus int
)
BEGIN
	select * from pizzaposdb.PosCheck
    where `IsActive` = IsActive and
    `TableID` = TableID and
    `UserID` = UserID and
    `CheckStatus` = CheckStatus;
END$$

drop procedure if exists delete_PosCheck$$
create procedure delete_PosCheck
(
	IN ID int,
    IN UUID varchar(36),
    IN IsActive bit,
    OUT retVal int
)
BEGIN
	UPDATE `pizzaposdb`.`poscheck`
	SET
		`IsActive` = IsActive
	WHERE `ID` = ID and `UUID` = UUID;
    SET retVal = successValue();
END$$

drop procedure if exists create_PosTables$$
create procedure create_PosTables
(
	IN TableName varchar(50),
    IN StoreID int,
	IN UUID varchar(36),
    IN IsActive bit,
    IN SortValue int,
    OUT ID int
)
Begin
	INSERT INTO `pizzaposdb`.`postables`
		(`UUID`,
		`SortValue`,
		`IsActive`,
		`TableName`,
		`StoreID`)
	VALUES
		(UUID,
        SortValue,
		IsActive,
		TableName,
		StoreID);
	SET ID = (SELECT `postables`.`ID`
		FROM `pizzaposdb`.`postables`
        Where `postables`.`UUID` = UUID and
			`postables`.`SortValue` = SortValue and
			`postables`.`IsActive` = IsActive and
			`postables`.`TableName` = TableName and
			`postables`.`StoreID` = StoreID);
END$$

Drop procedure if exists read_PosTable$$
create procedure read_PosTable
(
	IN IsActive bit,
    IN StoreID int
)
BEGIN
	SELECT * FROM `pizzaposdb`.`postables`
    WHERE `StoreID` = StoreID and
		`IsActive` = IsActive;
END$$

Drop procedure if exists update_PosTable$$
create procedure update_PosTable
(
	IN TableName varchar(50),
    IN StoreID int,
    IN ID int,
    IN UUID varchar(36),
    IN IsActive bit,
    IN SortValue int,
    OUT retVal int
)
BEGIN
	UPDATE `pizzaposdb`.`postables`
		SET
			`sortValue` = SortValue,
			`isActive` = IsActive,
			`TableName` = TableName,
			`StoreID` = StoreID
		WHERE `ID` = ID AND `UUID` = UUID;
	SET retVal = successValue();
END$$

Drop procedure if exists delete_PosTable$$
create procedure delete_PosTable
(
	IN ID int,
    IN UUID varchar(36),
    IN IsActive bit,
    OUT retVal int
)
BEGIN
	UPDATE `pizzaposdb`.`postables`
		SET
			`IsActive` = IsActive
		WHERE `ID` = ID AND `UUID` = UUID;
	SET retVal = successValue();
END$$

drop procedure if exists create_Ticket$$
create procedure create_Ticket
(
	IN DateStarted date,
    IN UserID int,
    IN TableID int,
    IN TicketStatus int,
    IN TicketType int,
	IN UUID varchar(36),
    IN IsActive bit,
    IN SortValue int,
    OUT ID int
)
BEGIN
	INSERT INTO `pizzaposdb`.`ticket`
		(`UUID`,
		`SortValue`,
		`IsActive`,
		`DateStarted`,
		`UserID`,
		`TableID`,
		`TicketStatus`,
		`TicketType`)
	VALUES
		(UUID,
        SortValue,
        IsActive,
        DateStarted,
        UserID,
        TableID,
        TicketStatus,
        TicketType);
	SET ID = (SELECT `ticket`.`ID`
		FROM `pizzaposdb`.`ticket`
        WHERE `ticket`.`UUID` = UUID AND
		`ticket`.`SortValue` = SortValue AND
		`ticket`.`IsActive` = IsActive AND
		`ticket`.`DateStarted` = DateStarted AND
		`ticket`.`UserID` = UserID AND
		`ticket`.`TableID` = TableID AND
		`ticket`.`TicketStatus`= TicketStatus AND
		`ticket`.`TicketType`= TicketType);
END$$

drop procedure if exists read_Ticket$$
create procedure read_Ticket
(
	IN UserID int,
    IN TableID int,
    IN IsActive int
)
BEGIN
	Select * from `pizzaposdb`.`Ticket`
    WHERE `UserID` = UserID and
    `TableID` = TableID and
    `IsActive` = IsActive;
END$$

drop procedure if exists update_Ticket$$
create procedure update_Ticket
(
	IN DateStarted date,
    IN UserID int,
    IN TableID int,
    IN TicketStatus int,
    IN TicketType int,
	IN ID int,
    IN UUID varchar(36),
    IN IsActive bit,
    IN SortValue int,
    OUT retVal int
)
BEGIN
	UPDATE `pizzaposdb`.`ticket`
		SET
			`SortValue` = SortValue,
			`IsActive` = IsActive,
			`DateStarted` = DateStarted,
			`UserID` = UserID,
			`TableID` = TableID,
			`TicketStatus` = TicketStatus,
			`TicketType` = TicketType
		WHERE `ID` = ID and `UUID` = UUID;
	SET retVal = successValue();
END$$

drop procedure if exists delete_Ticket$$
create procedure delete_Ticket
(
	IN ID int,
    IN UUID varchar(36),
    IN IsActive bit,
    OUT retVal int
)
BEGIN
	UPDATE `pizzaposdb`.`Ticket`
		SET `IsActive` = IsActive
        WHERE `ID` = ID and `UUID` = UUID;
	SET retVal = 1;
END$$

drop procedure if exists create_TicketItem$$
create procedure create_TicketItem
(
	IN TicketID int,
    IN MenuItemID int,
    IN ItemPrice double,
    IN UUID varchar(36),
    IN IsActive bit,
    IN SortValue int,
    OUT ID int
)
begin
	Insert into `pizzaposdb`.`TicketItem`
    (`UUID`,
    `IsActive`,
    `SortValue`,
    `TicketID`,
	`MenuItemID`,
    `ItemPrice`)
    values
    (UUID,
    IsActive,
    SortValue,
    TicketID,
    MenuItemID,
    ItemPrice);
	set ID = (select ID from `pizzaposdb`.`TicketItem`
		where `UUID` = UUID and
        `IsActive` = IsActive and
        `SortValue` = SortValue and
        `TicketID` = TicketID and
        `MenuItemID` = MenuItemID and
        `ItemPrice` = ItemPrice);
END$$

Drop procedure if exists read_TicketItem$$
create procedure read_TicketItem
(
	IN IsActive bit,
    IN MenuID int
)
begin
	select * from `pizzaposdb`.`TicketItem`
    where `IsActive` = IsActive and
    `MenuID` = MenuID;
end$$

Drop procedure if exists update_TicketItem$$
create procedure update_TicketItem
(
	IN TicketID int,
    IN MenuItemID int,
    IN ItemPrice double,
    IN ID int,
    IN UUID varchar(36),
    IN IsActive bit,
    IN SortValue int,
    OUT retVal int
)
begin
	update `pizzaposdb`.`TicketItem` set
		`IsActive` = IsActive,
        `SortValue` = SortValue,
        `TicketID` = TicketID,
        `MenuItemID` = MenuItemID,
        `ItemPrice` = ItemPrice
	where `ID` = ID and `UUID` = UUID;
    set retVal = 1;
end$$

Drop procedure if exists delete_TicketItem$$
create procedure delete_TicketItem
(
	IN ID int,
    IN UUID varchar(36),
    IN IsActive bit,
    OUT retVal int
)
begin
	update `pizzaposdb`.`TicketItem` set
		`IsActive` = IsActive
	where `ID` = ID and `UUID` = UUID;
    set retVal = successValue();
end$$

drop procedure if exists create_TransactionHistory$$
create procedure create_TransactionHistory
(
	IN FinalTotal double,
    IN CheckID int,
    IN UserID int,
    IN PaymentType int,
    IN PaymentStatus int,
    IN PaymentDate date,
    IN UUID varchar(36),
    IN IsActive bit,
    IN SortValue int,
    OUT ID int
)
begin
	insert into `pizzaposdb`.`TransactionHistory`
		(`UUID`,
        `IsActive`,
        `SortValue`,
        `FinalTotal`,
        `CheckID`,
        `UserID`,
        `PaymentType`,
        `PaymentStatus`,
        `PaymentDate`)
        values
        (UUID,
        IsActive,
        SortValue,
        FinalTotal,
        CheckID,
        UserID,
        PaymentType,
        PaymentStatus,
        PaymentDate);
	Set ID = (select ID from `pizzaposdb`.`TransactionHistory`
			where `UUID` = UUID and
			`IsActive` = IsActive and
			`SortValue` = SortValue and
			`FinalTotal` = FinalTotal and
			`CheckID` = CheckID and
			`UserID` = UserID and
			`PaymentType` = PaymentType and
			`PaymentStatus` = PaymentStatus and
			`PaymentDate` = PaymentDate);
end$$

drop procedure if exists read_TransactionHistory$$
create procedure read_TransactionHistory
(
	IN IsActive bit,
    IN UserID int,
    IN PaymentStatus int
)
begin
	select * from `pizzaposdb`.`TransactionHistory`
    where `UserID` = UserID and 
    `PaymentStatus` = PaymentStatus and
    `IsActive` = IsActive;
end$$

drop procedure if exists update_TransactionHistory$$
create procedure update_TransactionHistory
(
	IN FinalTotal double,
    IN CheckID int,
    IN UserID int,
    IN PaymentType int,
    IN PaymentStatus int,
    IN PaymentDate date,
    IN ID int,
    IN UUID varchar(36),
    IN IsActive bit,
    IN SortValue int,
    OUT retVal int
)
begin
	update `pizzaposdb`.`TransactionHistory` set
        `IsActive` = IsActive,
		`SortValue` = SortValue,
        `FinalTotal` = FinalTotal,
        `CheckID` = CheckID,
        `UserID` = UserID,
        `PaymentType` = PaymentType,
        `PaymentStatus` = PaymentStatus,
        `PaymentDate` = PaymentDate
        where `ID` = ID and `UUID` = UUID;
	set retVal = 1;
end$$

drop procedure if exists delete_TransactionHistory$$
create procedure delete_TransactionHistory
(
	IN ID int,
    IN UUID varchar(36),
    IN IsActive bit,
    OUT retVal int
)
begin
	update `pizzaposdb`.`TransactionHistory` set
        `IsActive` = IsActive
        where `ID` = ID  and `UUID` = UUID;
	set retVal = successValue();
end$$