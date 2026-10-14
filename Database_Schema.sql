CREATE TABLE "TransportTypes" (
  "ID" serial PRIMARY KEY,
  "Name" varchar
);

CREATE TABLE "Vehicles" (
  "ID" serial PRIMARY KEY,
  "TransportTypeID" int,
  "VIN" varchar UNIQUE,
  "Capacity" int,
  "Status" varchar,
  "IsDeleted" boolean DEFAULT false,
  "LastModifiedAt" timestamp,
  "LastModifiedBy" varchar
);

CREATE TABLE "Routes" (
  "ID" serial PRIMARY KEY,
  "RouteNumber" varchar,
  "Name" varchar,
  "TransportTypeID" int,
  "IsDeleted" boolean DEFAULT false
);

CREATE TABLE "Stops" (
  "ID" serial PRIMARY KEY,
  "Name" varchar,
  "Latitude" decimal,
  "Longitude" decimal
);

CREATE TABLE "RouteStops" (
  "ID" serial PRIMARY KEY,
  "RouteID" int,
  "StopID" int,
  "OrderIndex" int,
  "TimeToNext" int
);

CREATE TABLE "EmployeeRoles" (
  "ID" serial PRIMARY KEY,
  "Title" varchar
);

CREATE TABLE "Employees" (
  "ID" serial PRIMARY KEY,
  "RoleID" int,
  "FullName" varchar,
  "Phone" varchar,
  "IsDeleted" boolean DEFAULT false
);

CREATE TABLE "Shifts" (
  "ID" serial PRIMARY KEY,
  "EmployeeID" int,
  "VehicleID" int,
  "RouteID" int,
  "StartTime" timestamp,
  "EndTime" timestamp
);

CREATE TABLE "MaintenanceRecords" (
  "ID" serial PRIMARY KEY,
  "VehicleID" int,
  "MaintenanceDate" timestamp,
  "Description" text,
  "Cost" decimal
);

CREATE TABLE "TicketTypes" (
  "ID" serial PRIMARY KEY,
  "Name" varchar,
  "Price" decimal,
  "DurationDays" int
);

CREATE TABLE "Passengers" (
  "ID" serial PRIMARY KEY,
  "FullName" varchar,
  "Email" varchar UNIQUE,
  "CardNumber" varchar,
  "IsDeleted" boolean DEFAULT false,
  "LastModifiedAt" timestamp,
  "LastModifiedBy" varchar
);

CREATE TABLE "Tickets" (
  "ID" serial PRIMARY KEY,
  "PassengerID" int,
  "TicketTypeID" int,
  "PurchaseDate" timestamp,
  "ValidUntil" timestamp
);

CREATE TABLE "Transactions" (
  "ID" serial PRIMARY KEY,
  "PassengerID" int,
  "Amount" decimal,
  "TransactionDate" timestamp
);

CREATE TABLE "Incidents" (
  "ID" serial PRIMARY KEY,
  "VehicleID" int,
  "DriverID" int,
  "IncidentDate" timestamp,
  "Description" text,
  "Severity" varchar,
  "IsDeleted" boolean DEFAULT false,
  "LastModifiedAt" timestamp,
  "LastModifiedBy" varchar
);

CREATE TABLE "Feedbacks" (
  "ID" serial PRIMARY KEY,
  "PassengerID" int,
  "RouteID" int,
  "Rating" int,
  "Comment" text
);

CREATE TABLE "Schedules" (
  "ID" serial PRIMARY KEY,
  "RouteID" int,
  "DepartureTime" time,
  "ArrivalTime" time
);

ALTER TABLE "Vehicles" ADD FOREIGN KEY ("TransportTypeID") REFERENCES "TransportTypes" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Routes" ADD FOREIGN KEY ("TransportTypeID") REFERENCES "TransportTypes" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "RouteStops" ADD FOREIGN KEY ("RouteID") REFERENCES "Routes" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "RouteStops" ADD FOREIGN KEY ("StopID") REFERENCES "Stops" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Employees" ADD FOREIGN KEY ("RoleID") REFERENCES "EmployeeRoles" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Shifts" ADD FOREIGN KEY ("EmployeeID") REFERENCES "Employees" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Shifts" ADD FOREIGN KEY ("VehicleID") REFERENCES "Vehicles" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Shifts" ADD FOREIGN KEY ("RouteID") REFERENCES "Routes" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "MaintenanceRecords" ADD FOREIGN KEY ("VehicleID") REFERENCES "Vehicles" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Tickets" ADD FOREIGN KEY ("PassengerID") REFERENCES "Passengers" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Tickets" ADD FOREIGN KEY ("TicketTypeID") REFERENCES "TicketTypes" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Transactions" ADD FOREIGN KEY ("PassengerID") REFERENCES "Passengers" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Incidents" ADD FOREIGN KEY ("VehicleID") REFERENCES "Vehicles" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Incidents" ADD FOREIGN KEY ("DriverID") REFERENCES "Employees" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Feedbacks" ADD FOREIGN KEY ("PassengerID") REFERENCES "Passengers" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Feedbacks" ADD FOREIGN KEY ("RouteID") REFERENCES "Routes" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Schedules" ADD FOREIGN KEY ("RouteID") REFERENCES "Routes" ("ID") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Shifts" ADD FOREIGN KEY ("EmployeeID") REFERENCES "Shifts" ("ID") DEFERRABLE INITIALLY IMMEDIATE;
---------------------------------------------------------------------------------------------------------------------------
-- 1. B-Tree індекс для швидкого пошуку рейсів за маршрутом
CREATE INDEX idx_shifts_route ON "Shifts" USING btree ("RouteID");

-- 2. Partial (відфільтрований) індекс для Soft Delete сутностей (виключає видалені)
CREATE INDEX idx_active_passengers ON "Passengers" ("Email") WHERE "IsDeleted" = false;

-- 3. Hash індекс для точного пошуку за номером проїзної картки
CREATE INDEX idx_passenger_card ON "Passengers" USING hash ("CardNumber");
-----------------------------------------------------------------------------------------------------------------------------
-- ОБ'ЄКТ 1: Тригерна функція для автоматичного оновлення дати аудиту
CREATE OR REPLACE FUNCTION fn_UpdateAuditFields()
RETURNS TRIGGER AS $$
BEGIN
    NEW."LastModifiedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ОБ'ЄКТ 2: Тригер для сутності Vehicles
CREATE TRIGGER trg_Vehicles_Audit
BEFORE UPDATE ON "Vehicles"
FOR EACH ROW EXECUTE FUNCTION fn_UpdateAuditFields();

-- ОБ'ЄКТ 3: Тригер для сутності Passengers
CREATE TRIGGER trg_Passengers_Audit
BEFORE UPDATE ON "Passengers"
FOR EACH ROW EXECUTE FUNCTION fn_UpdateAuditFields();

-- ОБ'ЄКТ 4: Тригер для сутності Incidents
CREATE TRIGGER trg_Incidents_Audit
BEFORE UPDATE ON "Incidents"
FOR EACH ROW EXECUTE FUNCTION fn_UpdateAuditFields();

-- ОБ'ЄКТ 5: View - Активні транспортні засоби
CREATE OR REPLACE VIEW vw_ActiveVehicles AS
SELECT v."ID", v."VIN", t."Name" AS TransportType, v."Capacity", v."Status" 
FROM "Vehicles" v
JOIN "TransportTypes" t ON v."TransportTypeID" = t."ID"
WHERE v."IsDeleted" = false;

-- ОБ'ЄКТ 6: View - Деталі маршрутів із зупинками
CREATE OR REPLACE VIEW vw_RouteDetails AS
SELECT r."RouteNumber", r."Name" AS RouteName, s."Name" AS StopName, rs."OrderIndex"
FROM "Routes" r
JOIN "RouteStops" rs ON r."ID" = rs."RouteID"
JOIN "Stops" s ON rs."StopID" = s."ID"
WHERE r."IsDeleted" = false
ORDER BY r."RouteNumber", rs."OrderIndex";

-- ОБ'ЄКТ 7: View - Активні пасажири з придбаними квитками
CREATE OR REPLACE VIEW vw_PassengerTickets AS
SELECT p."ID", p."FullName", p."Email", t."Name" AS TicketType, tk."ValidUntil"
FROM "Passengers" p
JOIN "Tickets" tk ON p."ID" = tk."PassengerID"
JOIN "TicketTypes" t ON tk."TicketTypeID" = t."ID"
WHERE p."IsDeleted" = false AND tk."ValidUntil" > CURRENT_TIMESTAMP;

-- ОБ'ЄКТ 8: Збережена процедура - Soft Delete пасажира
CREATE OR REPLACE PROCEDURE sp_SoftDeletePassenger(p_PassengerID INT, p_ModifiedBy VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "Passengers"
    SET "IsDeleted" = true, "LastModifiedBy" = p_ModifiedBy, "LastModifiedAt" = CURRENT_TIMESTAMP
    WHERE "ID" = p_PassengerID;
END;
$$;

-- ОБ'ЄКТ 9: Збережена процедура - Реєстрація транзакції та видача квитка
CREATE OR REPLACE PROCEDURE sp_PurchaseTicket(
    p_PassengerID INT, p_TicketTypeID INT, p_Amount DECIMAL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_DurationDays INT;
BEGIN
    SELECT "DurationDays" INTO v_DurationDays FROM "TicketTypes" WHERE "ID" = p_TicketTypeID;
    
    INSERT INTO "Transactions" ("PassengerID", "Amount", "TransactionDate")
    VALUES (p_PassengerID, p_Amount, CURRENT_TIMESTAMP);
    
    INSERT INTO "Tickets" ("PassengerID", "TicketTypeID", "PurchaseDate", "ValidUntil")
    VALUES (p_PassengerID, p_TicketTypeID, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + (v_DurationDays || ' days')::interval);
END;
$$;

-- ОБ'ЄКТ 10: Користувацька функція - Підрахунок доходу за період
CREATE OR REPLACE FUNCTION fn_GetTotalRevenue(p_StartDate TIMESTAMP, p_EndDate TIMESTAMP)
RETURNS DECIMAL AS $$
DECLARE
    v_Total DECIMAL;
BEGIN
    SELECT COALESCE(SUM("Amount"), 0) INTO v_Total
    FROM "Transactions"
    WHERE "TransactionDate" BETWEEN p_StartDate AND p_EndDate;
    RETURN v_Total;
END;
$$ LANGUAGE plpgsql;
