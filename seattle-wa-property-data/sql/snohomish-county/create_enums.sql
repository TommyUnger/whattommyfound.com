 DROP TYPE IF EXISTS snohomish_county_use_type;  CREATE TYPE snohomish_county_use_type AS ENUM ('001 Reference Account', '110 Senior Citizen Exemption Residual', '111 Single Family Residence - Detached', '112 2 Single Family Residences', '113 3 Single Family Residences', '114 4 Single Family Residences', '115 5+ Single Family Residences', '116 Common Wall Single Family Residence', '117 Manufactured Home (Leased Site)', '118 Manufactured Home (Owned Site)', '119 Manufactured Home (Mobile Home Park)', '121 Two Family Residence convrtd from SFR (Duplex)', '122 Two Family Residence (Duplex)', '123 Three Family Residence (Tri-Plex)', '124 Four Family Residence (Four Plex)', '130 Multiple Family 5 - 7 Units', '131 Multiple Family 8 - 11 Units', '132 Multiple Family 12 - 15 Units', '133 Multiple Family 16 - 20 Units', '134 Multiple Family 21 - 30 Units', '135 Multiple Family 31 - 50 Units', '136 Multiple Family 51 - 100 Units', '137 Multiple Family 101 - 200 Units', '138 Multiple Family 201 - 300 Units', '139 Multiple Family 301 Units or More', '141 Single Family Residence Condominium Detached', '142 Single Family Residence Condominium Common Wal', '143 Single Family Residence Condominium Multiple', '144 Single Family Residence Condominium Project', '145 Condominium Conversion', '150 Mobile Home Park 1 - 20 Units', '151 Mobile Home Park 21 - 40 Units', '152 Mobile Home Park 41 - 60 Units', '153 Mobile Home Park 61 - 100 Units', '154 Mobile Home Park 101 - 200 Units', '155 Mobile Home Park 201 - 300 Units', '156 Mobile Home Park 301 Units or More', '160 Hotel / Motel 1 - 25 Units', '161 Hotel / Motel 26 - 50 Units', '162 Hotel / Motel 51 - 75 Units', '163 Hotel / Motel 76 - 100 Units', '164 Hotel / Motel 101 - 125 Units', '165 Hotel / Motel 126 - 200 Units', '166 Hotel / Motel 201+ Units', '174 Retirement Home / Orphanages', '175 Religious Residence', '179 Other Group Quarters', '182 Houseboat', '183 Non Residential Structure', '184 Septic System', '185 Well', '186 Septic & Well', '187 Non Res Structure Condo', '188 SFR Converted to Group Home', '189 Other Residential', '198 Vacation Cabins', '211 Meat Products', '214 Grain Mill Products', '218 Beverage', '219 Other Food Preparations & Kindred Products NEC', '229 Other Textile Goods NEC', '239 Other Fabricated Textile Products NEC', '241 Logging Camps & Logging Contractors', '242 Sawmills & Planing Mills', '243 Millwork, Veneer, Plywood & Prefab Struc. Wood', '244 Wooden Containers', '249 Other Lumber & Wood Products (Ex. Furnitu) NEC', '251 Household Furniture', '254 Partitions, Shelving, Lockers, Office & Store', '259 Other Furniture & Fixtures NEC', '262 Paper (Except Building Paper)', '271 Newspapers: Publishing, Publishing & Printing', '274 Commercial Printing', '278 Printing Trade Service Industries', '279 Other Printing & Publishing NEC', '282 Plastics & Synthetic Resins, Rubber, Ex. Glass', '292 Paving & Roofing Materials', '299 Other Petroleum Refining & Related Indus. NEC', '304 Miscellaneous Plastic Products', '309 Other Fabricated Rubber Products NEC', '321 Flat Glass', '322 Glass & Glassware (Pressed Or Blown)', '325 Pottery & Related Products', '326 Concrete, Gypsum & Plaster Products', '327 Cut Stone & Stone Products', '328 Abrasive, Asbestos & Miscellaneous Nonmetallic', '331 Steel Works, Rolling & Finishing Ferrous Metal', '332 Iron & Steel Foundries', '339 Other Primary Metal Industries NEC', '342 Machinery (Except Electrical)', '343 Electrical Machinery, Equipment & Supplies', '344 Transportation Equipment', '349 Other Fabricated Metal Products NEC', '351 Engineering, Lab & Scientific Research Instr.', '352 Instruments For Measuring', '390 Cannabis Processing', '393 Toys, Amusement, Sporting & Athletic Goods', '399 Other Miscellaneous Manufacturing NEC', '411 Railroad Transportation', '421 Bus Transportation', '422 Motor Freight Transportation', '429 Other Motor Vehicle Transportation NEC', '431 Airports & Flying Fields', '439 Other Aircraft Transportation NEC', '441 Marine Terminals', '451 Freeways', '453 Parkways', '454 Arterial Streets', '455 Collector / Distributor Streets', '456 Local Access Streets (Inc. Private Roads)', '457 Alleys', '459 Other Highway & Street Right-of-Way NEC', '461 Automobile Parking (Lot)', '471 Telephone Communication', '473 Radio Communication', '475 Radio & Television Communication (Combo System', '479 Other Communications NEC', '481 Electric Utility', '482 Gas Utility', '483 Water Utilities & Irrigation & Storage', '484 Sewage Disposal', '485 Solid Waste Disposal', '489 Other Utilities NEC', '491 Other Pipeline Right-of-Way & Pressure Control', '492 Transportation Services & Arrangements', '499 Other Trans. Communication & Utilities NEC', '502 Coml Condo - Manufacturing', '503 Coml Condo - Warehouse', '504 Coml Condo - Transportation', '505 Coml Condo - Trade', '506 Coml Condo - Services', '511 Motor Vehicles & Automotive Equipment', '512 Drugs, Chemical & Allied Products', '514 Groceries & Related Products', '515 Farm Products (Raw Materials)', '516 Electrical Goods', '517 Hardware, Plumbing, Heating Equip & Supplies', '518 Machinery, Equipment & Supplies', '519 Other Wholesale Trade, NEC', '521 Lumber & Other Building Materials', '522 Heating & Plumbing Equipment', '523 Paint, Glass & Wallpaper', '524 Electrical Supplies', '525 Hardware & Farm Equipment', '531 Department Stores', '539 Other Retail Trade NEC', '541 Groceries (With or Without Meat)', '542 Meats & Fish', '543 Fruits & Vegetables', '546 Bakeries', '549 Other Retail Trade - Food NEC', '551 Motor Vehicles', '552 Tires, Batteries & Accessories', '553 Gasoline Service Stations', '559 Other Retail Trade-Auto, Marine, Aircraft NEC', '564 Children''s & Infant''s Wear', '569 Other Retail Trade - Apparel & Accessories NEC', '571 Furniture, Home Furnishings & Equipment', '572 Household Appliances', '573 Radios, Televisions & Music Supplies', '581 Eating Places (Restaurants)', '582 Drinking Places (Alcoholic Beverages)', '590 Cannabis Products Retail', '591 Drug & Proprietary', '593 Antiques & Secondhand Merchandise', '594 Book & Stationery', '595 Sporting Goods & Bicycles', '596 Farm & Garden Supplies', '598 Fuel & Ice', '599 Other Retail Trade NEC', '611 Banking & Bank Related Functions', '614 Insurance Carriers, Agents, Brokers, Services', '615 Real Estate & Related Services', '616 Holding & Investment Services', '619 Other Finance Insurance & Real Estate Services', '621 Laundering, Dry Cleaning & Dyeing Services', '623 Beauty & Barber Services', '624 Funeral & Crematory Services (Inc. Cemeteries)', '629 Other Personal Services NEC', '637 Warehousing & Storage Services', '638 Mini-Warehouse', '639 Other Business Services NEC', '641 Automobile Repair & Services', '649 Other Repair Services NEC', '651 Medical & Other Health Services', '652 Legal Services', '659 Other Professional Services NEC', '661 General Contract Construction Services', '662 Special Construction Trade Services', '671 Executive, Legislative & Judicial Functions', '672 Protective Functions & Related Activities', '673 Postal Services', '674 Correctional Institutions', '675 Military Bases & Reservations', '681 Nursery, Primary & Secondary School', '682 University, College, Junior College, Etc.', '683 Special Training & Schooling', '691 Religious Activities (Churches Synagogues Etc.', '692 Welfare & Charitable Services', '699 Other Miscellaneous Services NEC', '711 Cultural Activities (Inc. Libraries)', '719 Other Cultural Activities & Nature Exhibitions', '721 Entertainment Assembly (Inc. Theaters)', '722 Sports Assembly', '723 Public Assembly', '729 Other Public Assembly, NEC', '731 Fairgrounds & Amusement Parks', '739 Other Amusements, NEC', '741 Sports Activities Inc. Golf Tennis Ice Etc.', '742 Playgrounds & Athletic Areas', '743 Swimming Areas', '744 Marinas', '745-Trails (Centennial, etal)', '749 Other Recreation NEC', '751 Resorts', '752 Group Or Organized Camps', '761 Parks - General Recreation', '762 Parks - Leisure & Ornamental', '769 Other Parks NEC', '790 Other Cultural, Entertainment, and Recreationa', '816 Farms & Ranches - Livestock (Not Dairy)', '817 Farms - Poultry', '818 Farms - General (No Predominant Activity)', '819 Other Agriculture & Related Activities NEC', '821 Agricultural Processing', '822 Animal Husbandry & Veterinary Services', '829 Other Agricultural Related Activities NEC', '830 Open Space Agriculture RCW 84.34', '841 Fisheries & Marine Products', '842 Fishery Services', '849 Other Fishery Activites & Related Services NEC', '850 Mining Claims, Mineral Rights or Mining NEC', '854 Mining & Quarrying - Non Metallic Minerals', '855 Mining Services', '860 Cannabis Growing', '880 DF Timber Acres Only RCW 84.33', '881 DF Timber Acres / Imp/Unimp Ac With Bldg', '889 DF Timber Acres / Imp/Unimp Ac No Bldg', '890 Other Resource Production & Extraction NEC', '910 Undeveloped (Vacant) Land', '911 Vacant Site Mobile Home Park', '912 No Perk Undeveloped Land', '914 Vacant Condominium Lot', '915 Common Areas', '916 Water Retention Area', '919 Trans Development Rights', '921 Forest Reserve', '922 Nonreserve Forests (Undeveloped)', '923 PILT NonCommercial Forest', '931 Rivers, Streams Or Creeks', '932 Lakes', '933 Bays Or Lagoons', '934 Oceans & Seas', '935 Saltwater Tidelands', '939 Other Water Areas, NEC', '940 Open Space General RCW 84.34', '941 Open Space General - Ag Cons RCW 84.34', '950 Open Space Timber RCW 84.34');

CREATE TYPE snohomish_sale_qual_code_typs AS ENUM (
'B'
, 'E'
, 'M'
, 'Q'
, 'V'
, 'Z'
, 'ZM'
);

CREATE TYPE snohomish_deed_type_typs AS ENUM (
'BS'
, 'BX'
, 'E'
, 'Q'
, 'QC'
, 'R'
, 'S'
, 'V'
, 'W'
, 'WP'
, 'X'
, 'Z'
, 'ZM'
, ''
);

CREATE TYPE snohomish_home_type_typs AS ENUM (
'DWELL'
, 'MHOME'
, ''
);

CREATE TYPE snohomish_building_type_type AS ENUM(
'1 1/2 STY'
, '1 1/2 STY B'
, '1 STY'
, '1 STY B'
, '2 STY'
, '2+ STY'
, '2 STY B'
, '2+ STY B'
, 'DBL WIDE'
, 'DBL WIDE B'
, 'MULTI LEVEL'
, 'QUAD LEVEL'
, 'SGL WIDE'
, 'SGL WIDE B'
, 'SPLIT ENTRY'
, 'TRI LEVEL'
, 'TRPL WIDE'
, ''
);