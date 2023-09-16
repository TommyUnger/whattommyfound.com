 DROP TYPE IF EXISTS king_county_type_1;  CREATE TYPE king_county_type_1 AS ENUM ('Agr classified under current use chapter 84.34 RCW', 'Agriculture (not classified under current use law)', 'Agriculture related activities', 'Aircraft transportation', 'All other residential not elsewhere coded', 'Amusements', 'Apparel & other finished products', 'Automobile parking', 'BUILDING ONLY', 'Business services', 'Chemicals', 'Communication', 'Condominiums - other than residential condominiums', 'Contract construction services', 'Cultural activities and nature exhibitions', 'Educational services', 'Fabricated metal products', 'Finance, insurance, and real estate services', 'Fishing activities and related services', 'Food and kindred products', 'Forest land designated under chapter 84.33 RCW', 'Furniture and fixtures', 'Governmental services', 'Highway and street right of way', 'Hotels/motels', 'Household, single family units', 'Improvements on leased land', 'Institutional lodging', 'LAND ONLY', 'Land with mobile home', 'LAND WITH MOBILE HOME', 'Land with new building', 'LAND WITH NEW BUILDING', 'LAND WITH PREV USED BLDG', 'Leather and leather products', 'Lumber and wood products (except furniture)', 'Marine craft transportation', 'Mining activities and related services', 'Miscellaneous manufacturing', 'Miscellaneous services', 'Mobile home parks or courts', 'Motor vehicle transportation', 'Multiple family residence (Residential, 2-4 units)', 'Multiple family residence (Residential, 5+ units)', 'Noncommercial forest', 'Open space land classified under chapter 84.34 RCW', 'Other cultural, entertainment, and recreational', 'Other resource production', 'Other transp., com., & util. not classified', 'Other undeveloped land', 'Paper and allied products', 'Parks', 'Personal services', 'Petroleum refining and related industries', 'Primary metal industries', 'Printing and publishing', 'Professional services (medical, dental, etc.)', 'Prof. scientific, controlling instr; optical goods', 'Public assembly', 'Railroad/transit transportation', 'Recreational activities (gold courses, etc.)', 'Repair services', 'Residential condominiums', 'Resorts and group camps', 'Retail trade - apparel and accessories', 'Retail trade-autom., marine craft, aircraft', 'Retail trade-bldg materials, hardware, farm equip', 'Retail trade-eating & drinking', 'Retail trade - food', 'Retail trade-furniture, home furnishings, equip.', 'Retail trade - general merchandise', 'Rubber and miscellaneous plastic products', 'Standing Timber (separate from land)', 'Stone, clay and glass products', 'Tenant occupied, commercial properties', 'Textile mill products', 'Timberland classified under chapter 84.34 RCW', 'TIMBER ONLY', 'Undeveloped land (land only)', 'Utilities', 'Vacation and cabin', 'Water areas', 'Water or Mineral rights', 'Wholesale trade');
 DROP TYPE IF EXISTS king_county_type_2;  CREATE TYPE king_county_type_2 AS ENUM ('AGRICULTURAL', 'APT(4+ UNITS)', 'COMMERCIAL', 'COMMERCIAL/INDUSTRIAL', 'CONDOMINIUM', 'INDUSTRIAL', 'MOBILE HOME', 'OTHER', 'RECREATIONAL', 'RESIDENTIAL', 'TIMBER');
 DROP TYPE IF EXISTS king_county_type_4;  CREATE TYPE king_county_type_4 AS ENUM ('C/I-Air rights only', 'C/I-Condominium', 'C/I-Imp prop excl air rights', 'C/I-Imp prop; no condo/MH', 'C/I-Land only', 'C/I-Land or bldg; no split', 'Res-Improved property', 'Res-Land only', 'Res or C/I-Mobile Home');
 DROP TYPE IF EXISTS king_county_type_5;  CREATE TYPE king_county_type_5 AS ENUM ('Assumption', 'Community Prop Established', 'Correction (refiling)', 'Divorce Settlement', 'Easement', 'Estate Settlement', 'Executor-to admin guardian', 'Foreclosure', 'Mortgage Assumption', 'None', 'Other', 'Partial Int - love,aff,gft', 'Property Settlement', 'Quit Claim Deed - gift/full or part interest', 'Settlement', 'Tenancy Partition', 'Testamentary Trust', 'Trade', 'Trust');
 DROP TYPE IF EXISTS king_county_type_6;  CREATE TYPE king_county_type_6 AS ENUM ('Assumption Warranty Deed', 'Bargain and Sales Deed', 'Contract (equity)', 'Contract (installment)', 'Corporate Warranty Deed', 'DEED', 'Deed of Personal Rep', 'Executor''s Deed', 'Fiduciary Deed', 'Forfeiture Real Estate Contract', 'Grant Deed', 'Judgment Per Stipulation', 'None', 'Other - See Affidavit', 'Purchaser''s Assignment', 'Quit Claim Deed', 'Real Estate Contract', 'Receivers Deed', 'Seller''s Assignment', 'Sheriff''s Deed', 'Special Warranty Deed', 'Statutory Warranty Deed', 'Trustees'' Deed', 'Warranty Deed');
 DROP TYPE IF EXISTS king_county_type_7;  CREATE TYPE king_county_type_7 AS ENUM ('$1,000 SALE OR LESS', '1031 TRADE', 'AFFORDABLE HOUSING SALES', 'ASSUMPTION OF MORTGAGE W/NO ADDL CONSIDERATION PD', 'AUCTION SALE', 'BANKRUPTCY - RECEIVER OR TRUSTEE', 'BUILDER OR DEVELOPER SALES', 'BUILDING ONLY', 'BULK PORTFOLIO SALE', 'CHANGE OF USE', 'CONDEMNATION/EMINENT DOMAIN', 'CONDO WHOLESALE', 'CONDO WITH GARAGE, MOORAGE, OR STORAGE', 'CONTRACT OR CASH SALE', 'CORPORATE AFFILIATES', 'CORRECTION DEED', 'DEVELOPMENT RIGHTS PARCEL TO PRVT SECTOR', 'DEVELOPMENT RIGHTS TO CNTY,CTY,OR PRVT DEVELOPER', 'DIVORCE', 'EASEMENT OR RIGHT-OF-WAY', 'ESTATE ADMINISTRATOR, GUARDIAN, OR EXECUTOR', 'EXEMPT FROM EXCISE TAX', 'FINANCIAL INSTITUTION RESALE', 'FORCED SALE', 'FULFILLMENT OF CONTRACT DEED', 'FULL SALES PRICE NOT REPORTED', 'GOV''T TO GOV''T', 'GOV''T TO NON-GOV''T', 'HISTORIC PROPERTY', 'IMP. CHARACTERISTICS CHANGED SINCE SALE', 'LEASE OR LEASE-HOLD', 'MOBILE HOME', 'MULTI-PARCEL SALE', 'NET LEASE SALE', 'NEW PLAT (WITH LESS THAN 20% SOLD)', 'NO MARKET EXPOSURE', 'NON-CONVENTIONAL HEATING SYSTEM', 'NON-GOV''T TO GOV''T', 'NON-PROFIT ORGANIZATION', 'NON-REPRESENTATIVE SALE', 'OPEN SPACE DESIGNATION CONTINUED/OK''D AFTER SALE', 'PARKING EASEMENT', 'PARKING STALLS', 'PARTIAL INTEREST (1/3, 1/2, Etc.)', 'PERSONAL PROPERTY INCLUDED', 'PLANS AND PERMITS', 'PLOTTAGE', 'PRELIMINARY SHORTPLAT APPROVAL', 'PRESALE', 'QUESTIONABLE PER APPRAISAL', 'QUESTIONABLE PER MAINFRAME SYSTEM (Obsolete code)', 'QUESTIONABLE PER SALES IDENTIFICATION', 'QUIT CLAIM DEED', 'REFUND', 'RELATED PARTY, FRIEND, OR NEIGHBOR', 'RELOCATION - SALE BY SERVICE', 'RELOCATION - SALE TO SERVICE', 'RESIDUAL SALES', 'SALE PRICE UPDATED BY SALES ID GROUP', 'SALES/LEASEBACK', 'SECURING OF DEBT', 'SEGREGATION AND/OR MERGER', 'SELLER''S OR PURCHASER''S ASSIGNMENT', 'SELLING OR BUYING COSTS AFFECTING SALE PRICE', 'SHELL', 'SHERIFF / TAX SALE', 'SHORT SALE', 'STATEMENT TO DOR', 'TEAR DOWN', 'TENANT', 'TIMBER AND FOREST LAND', 'TRADE');
 DROP TYPE IF EXISTS king_county_type_16;  CREATE TYPE king_county_type_16 AS ENUM ('AGRIC', 'CLFRS', 'FOREST LAND (84.33)', 'OPEN SPACE', 'TIMBER (84.34)');
 DROP TYPE IF EXISTS king_county_type_26;  CREATE TYPE king_county_type_26 AS ENUM ('Canopies', 'Carport', 'Car Wash', 'Fencing', 'FLAT-VALUED IMP', 'Flat-Valued SFR', 'Golf Course Imps', 'Jacuzzi', 'Kiosks', 'Loading Docks', 'M HOME:PERS', 'M HOME:REAL', 'Miscellaneous', 'MISC IMP', 'Mobile Home Pad', 'Moorage: Covrd', 'Moorage: Open', 'ON-SITE DEV CST', 'Overhead Doors', 'Paved Parking', 'Pkg: Covrd, Sec', 'Pkg: Covrd, Unsec', 'Pkg: Open, Sec', 'Pkg: Open, Unsec', 'Pool', 'POOL:CONCRETE', 'POOL:PLAS;FBGLS', 'PRK:CARPORT', 'PRK:DET GAR', 'PV:CONCRETE', 'Recreation Bldg', 'Retail Booths', 'Sauna', 'Shipping Docks', 'Sports Court', 'Storage Tanks', 'Yard Lighting');
 DROP TYPE IF EXISTS king_county_type_29;  CREATE TYPE king_county_type_29 AS ENUM ('Flat', 'Live/Work', 'NursHme/Hospital:1-bd rms', 'NursHme/Hospital:2-bd rms', 'NursHme/Hospital:3-bd rms', 'NursHme/Hospital:4-bd rms', 'Penthouse', 'Rooming House', 'Townhouse');
 DROP TYPE IF EXISTS king_county_type_40;  CREATE TYPE king_county_type_40 AS ENUM ('LinearFt', 'SqFt');
 DROP TYPE IF EXISTS king_county_type_43;  CREATE TYPE king_county_type_43 AS ENUM ('Coal & Mineral Rights', 'Commercial', 'Condominium', 'Exempt', 'Mining', 'Residential', 'Timber', 'Undivided Interest');
 DROP TYPE IF EXISTS king_county_type_47;  CREATE TYPE king_county_type_47 AS ENUM ('100% VALUE LAW 73', 'AMENDMENT', 'BOARD CHANGE', 'BOARD EXTENSION', 'B OF E CHANGE', 'CONDEMNATION', 'CO-OP SR CIT EX', 'CORRECTION', 'CORRECTION BOARD', 'COURT ORDER', 'DESTROYED PROPERTY', 'EXTENSION', 'FOREST LAND', 'HISTORIC PROPERTY', 'HOME IMP EXEMPTION', 'HOME IMP EXPIRED', 'JULY BOARD ORDER', 'JUNE BOARD ORDER', 'KILL BY CANCEL', 'KILL BY MERGE', 'LEGAL/ABATEMENT', 'LEGAL CHANGE', 'LEGAL CORRECTION', 'LEVY CODE CHNG', 'MAINT', 'MAINTENANCE', 'MERGE/CODE CHNG', 'MERGER', 'MERGE/STATUS CHNG', 'MOBILE HOME X-FER', 'NEW PARCEL', 'NEW PLAT', 'NONE', 'NOV BOARD ORDER', 'OMIT CORRECTION', 'OMIT REVISION', 'OMITTED ASSMT', 'OPEN SPACE', 'PLAT KILL', 'REACTVATED', 'REC-VALUE', 'REVALUE', 'REVALUE FACTOR', 'REVALUE - TIMBER', 'S.C. FROZEN VALUE', 'SEG/CODE CHNG', 'SEG OR MERGE', 'SEGREGATION', 'SEG/STATUS CHNG', 'SR CIT CHANGE', 'STATE BOARD ORDER', 'TAX STATUS CHNG', 'TIMBER-DEPL');
 DROP TYPE IF EXISTS king_county_type_50;  CREATE TYPE king_county_type_50 AS ENUM ('DUWAMISH', 'ELLIOTT BAY', 'LAKE SAMM', 'LAKE UNION', 'LAKE WASH', 'OTHER LAKE', 'PUGET SOUND', 'RIVER/SLOUGH', 'SHIP CANAL');
 DROP TYPE IF EXISTS king_county_type_51;  CREATE TYPE king_county_type_51 AS ENUM ('YES');
 DROP TYPE IF EXISTS king_county_type_52;  CREATE TYPE king_county_type_52 AS ENUM ('HIGH', 'LOW', 'MEDIUM', 'NO BANK');
 DROP TYPE IF EXISTS king_county_type_53;  CREATE TYPE king_county_type_53 AS ENUM ('No Waterfront Access', 'To Residence', 'To Waterfront');
 DROP TYPE IF EXISTS king_county_type_54;  CREATE TYPE king_county_type_54 AS ENUM ('TIDELANDS/SHORELANDS ONLY', 'UPLANDS ONLY', 'UPLANDS WITH TIDELANDS/SHORELANDS');
 DROP TYPE IF EXISTS king_county_type_55;  CREATE TYPE king_county_type_55 AS ENUM ('LEGAL/UNDEVELOPED', 'PRIVATE', 'PUBLIC', 'RESTRICTED', 'WALK IN');
 DROP TYPE IF EXISTS king_county_type_56;  CREATE TYPE king_county_type_56 AS ENUM ('PRIVATE', 'PRIVATE RESTRICTED', 'PUBLIC RESTRICTED', 'WATER DISTRICT');
 DROP TYPE IF EXISTS king_county_type_57;  CREATE TYPE king_county_type_57 AS ENUM ('PRIVATE', 'PRIVATE RESTRICTED', 'PUBLIC', 'PUBLIC RESTRICTED');
 DROP TYPE IF EXISTS king_county_type_58;  CREATE TYPE king_county_type_58 AS ENUM ('AVERAGE', 'EXCELLENT', 'FAIR', 'GOOD');
 DROP TYPE IF EXISTS king_county_type_59;  CREATE TYPE king_county_type_59 AS ENUM ('YES');
 DROP TYPE IF EXISTS king_county_type_60;  CREATE TYPE king_county_type_60 AS ENUM ('DIRT', 'GRAVEL', 'PAVED', 'UNDEVELOPED');
 DROP TYPE IF EXISTS king_county_type_66;  CREATE TYPE king_county_type_66 AS ENUM ('COMPLETE HVAC', 'CONTROL ATMOS., COND. AIR', 'CONTROL ATMOS., WARM/COOLED', 'ELECTRIC', 'ELECTRIC WALL', 'EVAPORATIVE COOLING', 'FLOOR FURNACE', 'FORCED AIR UNIT', 'HEAT PUMP', 'HOT & CHILLED WATER', 'HOT WATER', 'HOT WATER-RADIANT', 'NO HEAT', 'PACKAGE UNIT', 'REFRIGERATED COOLING', 'SPACE HEATERS', 'STEAM', 'STEAM WITHOUT BOILER', 'THRU-WALL HEAT PUMP', 'VENTILATION', 'WALL FURNACE', 'WARMED AND COOLED AIR');
 DROP TYPE IF EXISTS king_county_type_67;  CREATE TYPE king_county_type_67 AS ENUM ('DESIGNATED', 'DISTRICT', 'INVENTORY', 'VACANT HIST LAND');
 DROP TYPE IF EXISTS king_county_type_71;  CREATE TYPE king_county_type_71 AS ENUM ('BOARD MEMBER', 'EQUALIZATION PANEL', 'EXAMINER', 'FULL BOARD', 'MINI BOARD A', 'MINI BOARD B', 'MINI BOARD C', 'REVIEW; NO HEARING');
 DROP TYPE IF EXISTS king_county_type_72;  CREATE TYPE king_county_type_72 AS ENUM ('ASSESSOR', 'BOARD', 'TAXPAYER');
 DROP TYPE IF EXISTS king_county_type_73;  CREATE TYPE king_county_type_73 AS ENUM ('DISMISS', 'INVALIDATED', 'REVISE', 'REVISE, ASSESSOR RECOMMENDED', 'STIPULATED', 'SUSTAIN', 'TRANSFERRED', 'WITHDRAWN');
 DROP TYPE IF EXISTS king_county_type_80;  CREATE TYPE king_county_type_80 AS ENUM ('REVISE', 'STIPULATE', 'SUSTAIN');
 DROP TYPE IF EXISTS king_county_type_82;  CREATE TYPE king_county_type_82 AS ENUM ('10 Very Good', '11 Excellent', '12 Luxury', '13 Mansion', '1  Cabin', '2  Substandard', '3  Poor', '4  Low', '5  Fair', '6  Low Average', '7  Average', '8  Good', '9  Better', 'Exceptional Properties');
 DROP TYPE IF EXISTS king_county_type_83;  CREATE TYPE king_county_type_83 AS ENUM ('Average', 'Fair', 'Good', 'Poor', 'Very Good');
 DROP TYPE IF EXISTS king_county_type_84;  CREATE TYPE king_county_type_84 AS ENUM ('Electricity', 'Electricity/Solar', 'Gas', 'Gas/Solar', 'Oil', 'Oil/Solar', 'Other');
 DROP TYPE IF EXISTS king_county_type_89;  CREATE TYPE king_county_type_89 AS ENUM ('COMMON', 'PRIVATE');
 DROP TYPE IF EXISTS king_county_type_90;  CREATE TYPE king_county_type_90 AS ENUM ('YES');
 DROP TYPE IF EXISTS king_county_type_91;  CREATE TYPE king_county_type_91 AS ENUM ('YES');
 DROP TYPE IF EXISTS king_county_type_92;  CREATE TYPE king_county_type_92 AS ENUM ('ADEQUATE', 'INADEQUATE');
 DROP TYPE IF EXISTS king_county_type_93;  CREATE TYPE king_county_type_93 AS ENUM ('YES');
 DROP TYPE IF EXISTS king_county_type_95;  CREATE TYPE king_county_type_95 AS ENUM ('EXTREME', 'HIGH', 'MODERATE');
 DROP TYPE IF EXISTS king_county_type_96;  CREATE TYPE king_county_type_96 AS ENUM ('AVERAGE', 'AVERAGE/GOOD', 'EXCELLENT', 'GOOD', 'GOOD/EXCELLENT', 'LOW/AVERAGE', 'LOW COST');
 DROP TYPE IF EXISTS king_county_type_97;  CREATE TYPE king_county_type_97 AS ENUM ('MASONRY', 'PREFAB STEEL', 'REINFORCED CONCRETE', 'STRUCTURAL STEEL', 'WOOD FRAME');
 DROP TYPE IF EXISTS king_county_type_98;  CREATE TYPE king_county_type_98 AS ENUM ('ABOVE AVERAGE', 'AVERAGE', 'BELOW AVERAGE', 'EXCELLENT', 'SUBSTANDARD');
 DROP TYPE IF EXISTS king_county_type_99;  CREATE TYPE king_county_type_99 AS ENUM ('ABOVE AVERAGE', 'AVERAGE', 'BELOW AVERAGE', 'EXCELLENT', 'SUBSTANDARD');
 DROP TYPE IF EXISTS king_county_type_102;  CREATE TYPE king_county_type_102 AS ENUM ('4-Plex', 'Air Terminal and Hangers', 'Apartment', 'Apartment(Co-op)', 'Apartment(Mixed Use)', 'Apartment(Subsidized)', 'Art Gallery/Museum/Soc Srvc', 'Auditorium//Assembly Bldg', 'Auto Showroom and Lot', 'Bank', 'Bed & Breakfast', 'Bowling Alley', 'Campground', 'Car Wash', 'Church/Welfare/Relig Srvc', 'Club', 'Condominium(M Home Pk)', 'Condominium(Mixed Use)', 'Condominium(Office)', 'Condominium(Residential)', 'Congregate Housing', 'Conv Store with Gas', 'Conv Store without Gas', 'Daycare Center', 'Driving Range', 'Duplex', 'Easement', 'Farm', 'Forest Land(Class-RCW 84.33)', 'Forest Land(Desig-RCW 84.33)', 'Fraternity/Sorority House', 'Gas Station', 'Golf Course', 'Governmental Service', 'Greenhse/Nrsry/Hort Srvc', 'Grocery Store', 'Group Home', 'Health Club', 'High Tech/High Flex', 'Historic Prop(Eat/Drink)', 'Historic Prop(Loft/Warehse)', 'Historic Prop(Misc)', 'Historic Prop(Office)', 'Historic Prop(Park/Billbrd)', 'Historic Prop(Rec/Entertain)', 'Historic Prop(Residence)', 'Historic Prop(Retail)', 'Historic Prop(Transient Fac)', 'Historic Prop(Vacant Land)', 'Hospital', 'Hotel/Motel', 'Houseboat', 'Industrial(Gen Purpose)', 'Industrial(Heavy)', 'Industrial(Light)', 'Industrial Park', 'Marina', 'Medical/Dental Office', 'Mini Lube', 'Mining/Quarry/Ore Processing', 'Mini Warehouse', 'Mobile Home', 'Mobile Home Park', 'Mortuary/Cemetery/Crematory', 'Movie Theater', 'Nursing Home', 'Office Building', 'Office Park', 'Open Space(Agric-RCW 84.34)', 'Open Space(Curr Use-RCW 84.34)', 'Open Space Tmbr Land/Greenbelt', 'Parking(Assoc)', 'Parking(Commercial Lot)', 'Parking(Garage)', 'Park, Private(Amuse Ctr)', 'Park, Public(Zoo/Arbor)', 'Post Office/Post Service', 'Reforestation(RCW 84.28)', 'Rehabilitation Center', 'Reserve/Wilderness Area', 'Residence Hall/Dorm', 'Resort/Lodge/Retreat', 'Restaurant(Fast Food)', 'Restaurant/Lounge', 'Retail(Big Box)', 'Retail(Discount)', 'Retail(Line/Strip)', 'Retail Store', 'Retirement Facility', 'Right of Way/Utility, Road', 'River/Creek/Stream', 'Rooming House', 'School(Private)', 'School(Public)', 'Service Building', 'Service Station', 'Shell Structure', 'Shopping Ctr(Community)', 'Shopping Ctr(Maj Retail)', 'Shopping Ctr(Nghbrhood)', 'Shopping Ctr(Regional)', 'Shopping Ctr(Specialty)', 'Single Family(C/I Use)', 'Single Family(C/I Zone)', 'Single Family(Res Use/Zone)', 'Skating Rink(Ice/Roller)', 'Ski Area', 'Sport Facility', 'Tavern/Lounge', 'Terminal(Auto/Bus/Other)', 'Terminal(Grain)', 'Terminal(Marine)', 'Terminal(Marine/Comm Fish)', 'Terminal(Rail)', 'Tideland, 1st Class', 'Tideland, 2nd Class', 'Townhouse Plat', 'Transferable Dev Rights', 'Triplex', 'Utility, Private(Radio/T.V.)', 'Utility, Public', 'Vacant(Commercial)', 'Vacant(Industrial)', 'Vacant(Multi-family)', 'Vacant(Single-family)', 'Vet/Animal Control Srvc', 'Warehouse', 'Water Body, Fresh');
 DROP TYPE IF EXISTS king_county_type_103;  CREATE TYPE king_county_type_103 AS ENUM ('AGRICULTURAL', 'AMUSEMENT/ENTERTAINMENT', 'COMMERCIAL SERVICE', 'CULTURAL', 'DUPLEX', 'EDUCATIONAL SERVICE', 'FISH & WILDLIFE MGMT', 'FORESTRY', 'GROUP RESIDENCE', 'MANUFACTURING', 'MINERAL', 'MIXED USE', 'MOBILE HOME', 'MULTI-FAMILY DWELLING', 'OTHER SF DWELLING', 'PARK/RECREATION', 'REGIONAL LAND USE', 'RETAIL/WHOLESALE', 'SINGLE FAMILY', 'TEMPORARY LODGING', 'TRIPLEX');
 DROP TYPE IF EXISTS king_county_type_104;  CREATE TYPE king_county_type_104 AS ENUM ('INTERIM USE', 'OTHER', 'PRESENT USE', 'TEAR DOWN');
 DROP TYPE IF EXISTS king_county_type_105;  CREATE TYPE king_county_type_105 AS ENUM ('Separate Value');
 DROP TYPE IF EXISTS king_county_type_106;  CREATE TYPE king_county_type_106 AS ENUM ('Approx Square', 'Long Rect or Irreg', 'Rect or Slight Irreg', 'Very Irreg');
 DROP TYPE IF EXISTS king_county_type_108;  CREATE TYPE king_county_type_108 AS ENUM ('Elec BB', 'Floor-Wall', 'Forced Air', 'Gravity', 'Heat Pump', 'Hot Water', 'Other', 'Radiant');
 DROP TYPE IF EXISTS king_county_type_109;  CREATE TYPE king_county_type_109 AS ENUM ('Apartments, HUD', 'Appl review reqd', 'Build tran err', 'Contamintated Property', 'Exceptional Properties Review Reqd', 'HI on UI/Split', 'Holdout: AffordableHousing', 'Holdout: M1', 'Mainframe posting error', 'Misc: do not post', 'Misc; post manually', 'NProfit pcnt error', 'Post Condo Units', 'Posted', 'Posted via GCO', 'Ready to post', 'Review Seg/BrdOrder', 'Review Val Dist spec', 'SplitAcct Prcl; post split appsls', 'UndInt Prcl; post split appsls', 'Value Select exceed threshold', 'Value too large');
 DROP TYPE IF EXISTS king_county_type_112;  CREATE TYPE king_county_type_112 AS ENUM ('ACCOUNT STATUS', 'Board Order', 'Char Update', 'CONDOMINIUM', 'CORRECTION', 'DRAIN/FFIRE/ABATEMNT', 'Kill', 'Legal Change', 'Levy Code', 'MIGRATION', 'MISC RECEIVABLE', 'NAME/ADDRESS', 'NEW CONSTRUCTION', 'New Parcel', 'New Plat', 'OTHER TAX CORRECTION', 'Preliminary Plat', 'REVALUE', 'Seg Merge', 'SR CIT EXEMPTION', 'TAX STATUS', 'Transfer', 'Unkill');
 DROP TYPE IF EXISTS king_county_type_118;  CREATE TYPE king_county_type_118 AS ENUM ('Administrative Office (600)', 'Alternative School (156)', 'APARTMENT (300)', 'ARCADE (573)', 'ARMORY (301)', 'AUDITORIUM (302)', 'AUTO DEALERSHIP, COMPLETE (455)', 'AUTOMOBILE SHOWROOM (303)', 'AUTOMOTIVE CENTER (410)', 'BANK (304)', 'Banquet Hall (718)', 'BARBER SHOP (384)', 'BARN (305)', 'Barn, General Purpose (102)', 'Barn, Special Purpose (103)', 'BAR/TAVERN (442)', 'BASEMENT, DISPLAY (704)', 'BASEMENT, FINISHED (701)', 'BASEMENT, OFFICE (705)', 'BASEMENT, PARKING (706)', 'BASEMENT, RESIDENT LIVING (707)', 'BASEMENT, RETAIL (709)', 'BASEMENT, SEMIFINISHED (702)', 'BASEMENT, STORAGE (708)', 'BASEMENT, UNFINISHED (703)', 'Boat Storage Building (467)', 'Boat Storage Shed (466)', 'BOWLING ALLEY (306)', 'BROADCAST FACILITIES (498)', 'CAFETERIA (530)', 'Car Wash - Automatic (436)', 'Car Wash - Canopy (508)', 'Car Wash - Drive Thru (435)', 'Car Wash - Self Serve (434)', 'Casino (515)', 'CHURCH (309)', 'Church Educational Wing (173)', 'CHURCH WITH SUNDAY SCHOOL (308)', 'CITY CLUB (310)', 'Classroom (356)', 'Classroom (College) (368)', 'CLUBHOUSE (311)', 'COCKTAIL LOUNGE (441)', 'COLD STORAGE FACILITIES (447)', 'COLLEGE (ENTIRE) (377)', 'Commons (College) (369)', 'Community Center (514)', 'COMMUNITY SHOPPING CENTER (413)', 'COMPUTER CENTER (497)', 'CONDO HOTEL, FULL SERVICE (852)', 'CONDO HOTEL, LIMITED SERVICE (853)', 'CONDO, OFFICE (845)', 'CONDO, PARKING STRUCTURE (850)', 'CONDO, RETAIL (846)', 'CONDO, STORAGE (849)', 'CONGREGATE HOUSING (982)', 'Controlled Atmosphere Storage (106)', 'CONVALESCENT HOSPITAL (313)', 'CONVENIENCE MARKET (419)', 'CONVENTION CENTER (482)', 'COUNTRY CLUB (314)', 'CREAMERY (315)', 'DAIRY (316)', 'DAIRY SALES BUILDING (317)', 'DAY CARE CENTER (426)', 'DENTAL OFFICE/CLINIC (444)', 'DEPARTMENT STORE (318)', 'DISCOUNT STORE (319)', 'DISPENSARY (320)', 'DORMITORY (321)', 'Drug Store (511)', 'Dry Cleaners-Laundry (499)', 'ELEMENTARY SCHOOL (ENTIRE) (365)', 'EQUIPMENT SHED (472)', 'EQUIPMENT (SHOP) BUILDING (470)', 'FARM UTILITY BUILDING (477)', 'Farm Utility Storage Shed (479)', 'FAST FOOD RESTAURANT (349)', 'FIELD HOUSES (486)', 'Fine Arts & Crafts Building (355)', 'FIRE STATION (STAFFED) (322)', 'FIRE STATION (VOLUNTEER) (427)', 'FITNESS CENTER (483)', 'FLORIST SHOP (532)', 'Food Booth - Prefabricated (465)', 'FRATERNAL BUILDING (323)', 'FRATERNITY HOUSE (324)', 'GARAGE, SERVICE REPAIR (528)', 'GARAGE, STORAGE (326)', 'Golf Cart Storage Building (523)', 'GOVERNMENT BUILDING (327)', 'GOVERNMENT COMMUNITY SERVICE BUILDING (491)', 'Greenhouse, Hoop, Arch-Rib, Medium (141)', 'Greenhouse, Hoop, Arch-Rib, Small (135)', 'GROUP CARE HOME (424)', 'Gymnasium (School) (358)', 'HANDBALL-RACQUETBALL CLUB (417)', 'HANGAR, MAINTENANCE & OFFICE (329)', 'HANGAR, STORAGE (328)', 'HEALTH CLUB (418)', 'HIGH SCHOOL (ENTIRE) (484)', 'HOME FOR THE ELDERLY (330)', 'HORSE ARENA (428)', 'HOSPITAL (331)', 'Hotel, Full Service (594)', 'HOTEL, FULL SERVICE (841)', 'HOTEL, LIMITED (332)', 'Hotel, Limited Service (595)', 'HOTEL, SUITE (842)', 'Individual Livestock Shelter (132)', 'INDUSTRIAL ENGINEERING BUILDING (392)', 'INDUSTRIAL FLEX BUILDINGS (453)', 'INDUSTRIAL HEAVY MANUFACTURING (495)', 'INDUSTRIAL LIGHT MANUFACTURING (494)', 'JAIL-CORRECTIONAL FACILITY (335)', 'JAIL - POLICE STATION (489)', 'JUNIOR HIGH SCHOOL (ENTIRE) (366)', 'KENNELS (490)', 'LABORATORIES (496)', 'LAUNDROMAT (336)', 'LIBRARY, PUBLIC (337)', 'Light Commercial Manufacturing Utility Bldg (186)', 'LIGHT COMMERCIAL UTILITY BUILDING (471)', 'LINE RETAIL (860)', 'Loafing Shed (113)', 'Lodge (537)', 'LOFT (338)', 'Lumber Storage Bldg., Vert. (390)', 'LUMBER STORAGE SHED, HORIZONTAL (339)', 'Luxury Apartment (984)', 'Maintenance Storage Building (157)', 'Mall Anchor Department Store (700)', 'MARKET (340)', 'Material Shelter (473)', 'MATERIAL STORAGE BUILDING (391)', 'MEDICAL OFFICE (341)', 'Mega Warehouse (584)', 'Milkhouse Shed (114)', 'Mini-Bank (578)', 'MINI-LUBE GARAGE (423)', 'MINI-MART CONVENIENCE STORE (531)', 'MINI-WAREHOUSE (386)', 'MINI WAREHOUSE, HI-RISE (525)', 'Mixed Retail w/ Office Units (597)', 'MIXED RETAIL W/RES. UNITS (459)', 'MIXED USE OFFICE (840)', 'MIXED USE-OFFICE CONDO (847)', 'MIXED USE RETAIL (830)', 'MIXED USE-RETAIL CONDO (848)', 'MORTUARY (342)', 'MOTEL, EXTENDED STAY (588)', 'MOTEL, FULL SERVICE (843)', 'MOTEL, LIMITED (343)', 'MOTEL, SUITE (844)', 'MULTIPLE RESIDENCE (LOW RISE) (352)', 'MULTIPLE RESIDENCE, RETIREMENT COMMUNITY COMPLEX', 'MULTIPLE RESIDENCES ASSISTED LIVING (LOW RISE)', 'MULTIPLE RESIDENCE (SENIOR CITIZEN) (451)', 'Multi-Purp Bldg (College) (374)', 'MUNICIPAL SERVICE GARAGE (527)', 'MUSEUM (481)', 'NATATORIUM (485)', 'NEIGHBORHOOD SHOPPING CENTER (412)', 'OFFICE BUILDING (344)', 'OPEN OFFICE (820)', 'Outbuildings (162)', 'OUTPATIENT SURGICAL CENTER (431)', 'PARKING STRUCTURE (345)', 'Passenger Terminal (571)', 'POST OFFICE - BRANCH(582)', 'POST OFFICE - MAIL PROCESSING(583)', 'POST OFFICE - MAIN(581)', 'POULTRY HOUSE-FLOOR OPERATION (475)', 'Prefabricated Storage Shed (133)', 'Regional Discount Shopping Center (513)', 'REGIONAL SHOPPING CENTER (414)', 'Residence (348)', 'Residential Garage - Detached (152)', 'RESTAURANT, TABLE SERVICE (350)', 'RESTROOM BUILDING (432)', 'RETAIL STORE (353)', 'ROOMING HOUSE (551)', 'Senior Center (985)', 'Service Garage Shed (526)', 'Service Station (408)', 'SHED, MATERIAL STORAGE (468)', 'Shell, Apartment (596)', 'Shell, Community Shop. Ctr. (461)', 'Shell, Elderly Assist. Multi. Res. (782)', 'Shell, Industrial (454)', 'Shell, Multiple Residence (587)', 'Shell, Multiple Res. (Sen. Citizen) (784)', 'Shell, Neigh. Shop. Ctr. (460)', 'Shell, Office (492)', 'Shell, Regional Shop. Ctr. (462)', 'Shell, Retirement Community Complex (783)', 'Single-Family Residence (351)', 'Site Improvements (163)', 'SKATING RINK (405)', 'Skating Rink, Ice (175)', 'Skating Rink, Roller (176)', 'SNACK BAR (529)', 'STABLE (378)', 'STORAGE WAREHOUSE (406)', 'SUPERMARKET (446)', 'TENNIS CLUB, INDOOR (416)', 'T-HANGAR (409)', 'THEATER, CINEMA (380)', 'THEATER, LIVE STAGE (379)', 'Tool Shed (456)', 'TRANSIT WAREHOUSE (387)', 'Truck Wash (185)', 'UNDERGROUND CONDO PARKING (851)', 'UNDERGROUND PARKING STRUCTURE (388)', 'VETERINARY HOSPITAL (381)', 'VISITOR CENTER (574)', 'VOCATIONAL SCHOOLS (487)', 'WAREHOUSE DISCOUNT STORE (458)', 'WAREHOUSE, DISTRIBUTION (407)', 'WAREHOUSE FOOD STORE (533)', 'WAREHOUSE OFFICE (810)', 'WAREHOUSE SHOWROOM STORE (534)');
 DROP TYPE IF EXISTS king_county_type_119;  CREATE TYPE king_county_type_119 AS ENUM ('BALCONY (751)', 'MEZZANINES-DISPLAY (760)', 'MEZZANINES-OFFICE (761)', 'MEZZANINES-STORAGE (763)');
 DROP TYPE IF EXISTS king_county_type_122;  CREATE TYPE king_county_type_122 AS ENUM ('AcctNbr Changed', 'Active', 'Amended', 'Amended Appeal Record', 'Appeal Filed', 'Appeal to State', 'Appellant Info', 'Assigned', 'Binder Prepared', 'Board Order Issued', 'BTA Scheduling', 'Case File Transferred Voided', 'Case Order Review Voided', 'Case Prepared', 'Case Prepared Voided', 'Case Reviewed', 'Case Reviewed Voided', 'Change Assignment', 'Completed', 'Contact', 'Decision Cancelled Pending', 'Decision Changed Pending', 'Decision Reviewed', 'Decision Review Pending', 'Denied', 'Direct Appeal Request', 'Exception Acknowledgement Letter', 'Fast Track', 'Hearing Cancelled', 'Hearing Completed', 'Hearing Rescheduled', 'Hearing Scheduled', 'Order Denying Exception Response', 'Order Denying Exceptions To Proposed Decision', 'Order Denying Motion', 'Order Denying Petition for Review', 'Order Granting Exception Response', 'Order Granting Exceptions to Proposed Decision', 'Order Granting Motion', 'Order Granting Petition for Review', 'Other', 'Petition Reactivated by the Board', 'Ready to Mail', 'Received', 'Reconvene Request', 'Response to Reconvene Request', 'Set StatusAssmtReview to Active', 'Stipulation Finalized', 'Stipulation Finalized Voided', 'Stipulation Pending', 'Stipulation Pending Voided', 'Stipulation Prepared', 'Stipulation Prepared Voided', 'Stipulation Rejected', 'Stipulation Reviewed', 'Stipulation Reviewed Voided', 'Stipulation Voided', 'Submitted to Board', 'Taxpayer Signed Stipulation', 'Threshold Reviewed', 'TP Effort to Confer', 'TP Evidence Previously Submitted to BOE', 'TP Letter of Exception', 'TP Motion', 'TP New Evidence', 'TP Opening Brief/Statement', 'TP Rebuttal Evidence', 'TP Reply Brief/Statement', 'TP Response to Exception', 'TP Response to Motion', 'TRC', 'Undeliverable email', 'Untimely Info', 'Void', 'Withdrawal Letter', 'Withdrawn');
 DROP TYPE IF EXISTS king_county_type_124;  CREATE TYPE king_county_type_124 AS ENUM ('Appraised Value', 'Assessed Value', 'Other');
 DROP TYPE IF EXISTS king_county_type_125;  CREATE TYPE king_county_type_125 AS ENUM ('Appealed Value', 'Assessor Recommended Value', 'Board Order Value', 'Stipulated', 'Taxpayer Recommended');
 DROP TYPE IF EXISTS king_county_type_128;  CREATE TYPE king_county_type_128 AS ENUM ('Comparable Property Sales', 'Conflict of Interest: Uphold', 'Cost Approach to Value', 'Cost to Cure', 'Deferred Maintenance', 'Documented Non-Perc', 'Evidence Not Persuasive', 'Expense to Develop', 'Improvement Obsolescence', 'Income Analysis', 'Incorrect Characteristic', 'Insufficient Evidence: Uphold', 'Land Features', 'Neighborhood Nuisance', 'Other', 'Purchase Price', 'Total Value Supported: Uphold', 'Value Allocated to Land, Imp Low', 'Value-Limiting Location', 'Within Market: Uphold');
 DROP TYPE IF EXISTS king_county_type_129;  CREATE TYPE king_county_type_129 AS ENUM ('APPR', 'EMV', 'EMV/ADJ', 'PREV APPR', 'RCN', 'RCN/ADJ', 'RCNLD', 'RCNLD/ADJ');
 DROP TYPE IF EXISTS king_county_type_130;  CREATE TYPE king_county_type_130 AS ENUM ('APPR', 'COMP SALES', 'EMV', 'GIM VAL', 'INCOME', 'INCOME APT', 'Income Override', 'MARKET', 'PREV APPR', 'RCN', 'RCNLD', 'Reconciled', 'WEIGHTED', 'Weighted Override');
 DROP TYPE IF EXISTS king_county_type_131;  CREATE TYPE king_county_type_131 AS ENUM ('Appeal', 'Assmt/CharRevw', 'DestroyedProp', 'New Accy', 'NewConstr', 'New Imp', 'New Plat', 'OpenSpace', 'Other', 'Remodel', 'Revalue-AnnlUpdt', 'Revalue-CharUpdt', 'Revalue-PhysInsp', 'SegMerge', 'Transfer');
 DROP TYPE IF EXISTS king_county_type_132;  CREATE TYPE king_county_type_132 AS ENUM ('Appeal', 'Assmt/CharRevw', 'DestroyedProp', 'NewConstr', 'OpenSpace', 'Other', 'Revalue', 'SegMerge');
 DROP TYPE IF EXISTS king_county_type_137;  CREATE TYPE king_county_type_137 AS ENUM ('Appraised Value', 'Improvement Characteristics', 'Site Characteristics');
 DROP TYPE IF EXISTS king_county_type_140;  CREATE TYPE king_county_type_140 AS ENUM ('Court', 'Local Appeal', 'Review - Assessment', 'Review - Characteristics', 'Review - Destruct', 'State Appeal');
 DROP TYPE IF EXISTS king_county_type_143;  CREATE TYPE king_county_type_143 AS ENUM ('Commercial', 'Condo,Commercial', 'Condo,Floating Home', 'Condo,Mobile Home', 'Condo,Residential', 'Condo,Residential(Apt Use)', 'Condo,Residential(Apt Use)+Commercial', 'Condo,Residential+Commercial', 'Condo,Residential+Residential(Apt Use)');
 DROP TYPE IF EXISTS king_county_type_145;  CREATE TYPE king_county_type_145 AS ENUM ('Air Rights', 'Bldg Only', 'Fee Simple', 'Land Only', 'Leased Land');
 DROP TYPE IF EXISTS king_county_type_146;  CREATE TYPE king_county_type_146 AS ENUM ('Average', 'Excellent', 'Fair', 'Good', 'Poor', 'Very Good');
 DROP TYPE IF EXISTS king_county_type_150;  CREATE TYPE king_county_type_150 AS ENUM ('Apartments', 'Detached SFR', 'Development Rights', 'Dock', 'Flat', 'Floating Home, Flat', 'Floating Home, Townhouse', 'Hangar', 'Hotel', 'Land Only', 'Leased Land', 'Live/Work', 'Marina', 'Mobile Home', 'Moorage, Covered', 'Moorage, Open', 'Office', 'Other Commercial', 'Parking', 'Penthouse,Flat', 'Penthouse,Townhouse', 'Retail', 'Storage', 'Townhouse', 'Unassigned Moorage, Covered', 'Unassigned Moorage, Open', 'Unassigned Parking', 'Unassigned Storage', 'Warehouse');
 DROP TYPE IF EXISTS king_county_type_151;  CREATE TYPE king_county_type_151 AS ENUM ('Average', 'Excellent', 'Fair', 'Good');
 DROP TYPE IF EXISTS king_county_type_152;  CREATE TYPE king_county_type_152 AS ENUM ('Excellent', 'Fair', 'Good', 'Standard');
 DROP TYPE IF EXISTS king_county_type_155;  CREATE TYPE king_county_type_155 AS ENUM ('Excellent', 'Fair', 'Good', 'Standard');
 DROP TYPE IF EXISTS king_county_type_156;  CREATE TYPE king_county_type_156 AS ENUM ('Den', 'Loft');
 DROP TYPE IF EXISTS king_county_type_157;  CREATE TYPE king_county_type_157 AS ENUM ('Average', 'Excellent', 'Fair', 'Good');
 DROP TYPE IF EXISTS king_county_type_159;  CREATE TYPE king_county_type_159 AS ENUM ('Hydraulic', 'Other');
 DROP TYPE IF EXISTS king_county_type_161;  CREATE TYPE king_county_type_161 AS ENUM ('Applicant Address', 'Applicant Name', 'Applicant Phone Nbr', 'Architect Address', 'Architect License Nbr', 'Architect Name', 'Architect Phone Nbr', 'Class', 'Construction', 'Contractor Address', 'Contractor License Nbr', 'Contractor Name', 'Contractor Phone Nbr', 'Expiration Date', 'Nbr Bedrooms', 'Nbr Buildings', 'Nbr Stories', 'Nbr Units', 'Occupancy', 'Other Description', 'Owner Name', 'Owner-Reported Value', 'Project Name', 'Property Address', 'Sewer System', 'Square Feet', 'Subdivision / Lot', 'Water System', 'Zoning');

