local metadata = {
"## Interface: 1.4.4.0 1.4.4RC8",
"## Title: NewFillTypes",
"## Notes: FS2017 Script for registering FillTypes, via modDesc.xml für platzierbare Mods",
"## Author: Blacksheep(RC-Devil)",
"## Version: 1.0.0.1",
"## Date: 13.03.2017",
"## Web: http://www.farming-mods.de"
}
--
-- newFillTypes
--
-- @author: Blacksheep(RC-Devil)
-- @version: 1.0.0.1
-- @date: 13 March 2017
--
-- Copyright (C) 2016 - 2017 Blacksheep(RC-Devil)
--
-- @Informations:
--[[
-- ############################################################################################################################################# --
	  For Spreader added new Entries: 
	  useForSpray="false" let it to false to use it not for spreader or sprayer, it is set to true, to use it for.
	  sprayerCategorys="manureSpreader spreader sprayer" Possible entries: manureSpreader spreader sprayer
	  
	  FillTypeCaregorys: bulk liquid windrow piece combine forageHarvester forageWagon slurryTank manureSpreader spreader sprayer fork trainWagon augerWagon
	
	This is an example part for set in the modDesc.xml
	
	<newFillTypes hudsDirectory="fruitHuds/" groundTipDirectory="tipOnGround/" materialDirectory="masterialDir/" hasHolders="false">	  
	  <fillType name="seeds2" pricePerLiter="0.8" showOnPriceTable="true" litersPerSecond="0.007" massPerLiter="350" useForSpray="false" sprayerCategorys="spreader manureSpreader" toCategorys="true" fillTypeCategorys="bulk" hasMaterials="true" hasParticles="true" useHeap="true" isCowBasefeed="false" isCowGrass="false" isCowPower="false" isCowWindrow="false" isSheepGrass="false" isPigBasefeed="false" isPigGrain="false" isPigProtein="false" isPigEarthfruit="false" />
	  <fillType name="lime" pricePerLiter="0.8" showOnPriceTable="true" litersPerSecond="0.0060" massPerLiter="1000" useForSpray="true" sprayerCategorys="spreader" toCategorys="true" fillTypeCategorys="bulk trainWagon augerWagon" hasMaterials="true" hasParticles="true" useHeap="true" />
	  <fillType name="compost" pricePerLiter="0.8" showOnPriceTable="true" litersPerSecond="0.3244" massPerLiter="800" useForSpray="true" sprayerCategorys="manureSpreader" toCategorys="true" fillTypeCategorys="bulk windrow forageWagon fork trainWagon augerWagon" hasMaterials="true" hasParticles="true" useHeap="true" />
	  <fillType name="sand" pricePerLiter="0.8" showOnPriceTable="true" litersPerSecond="0.0060" massPerLiter="1000" toCategorys="true" fillTypeCategorys="bulk trainWagon augerWagon" hasMaterials="true" hasParticles="true" useHeap="true" />
	</newFillTypes>
	
	Informations about the Texture Filenames
	Hud Texture Format: DTX5 256x256px and small DTX5 64x64px
	Hud Textures Filename-Format: 
    for FruitTypehuds: hud_fruit_rye.dds and hud_fruit_rye_small.dds 
	for FillTypehuds: hud_fill_sand.dds and hud_fill_sand_small.dds
	for Windrow Types: hud_oat_windrow.dds and hud_oat_windrow_small.dds
	
	GroundTip Texture Formats: 
	diffuse DTX5 use MipMap 512x512px
	normal DTX1 use MipMap 512x512px
	distance DTX1 use MipMap 256x256ps
	
	GroundTip Textures Filename-Format:
	for diffuse Textures: lime_diffuse.dds
	for normal Textures: lime_normal.dds
	for distance Textures: limeDistance_diffuse.dds
	
-- ############################################################################################################################################# --
--]]

--[[
For Debugging: 
Standard DebugEbene = 0;
set DebugEbene: 1; for Debug Lines from FillTypes,
set DebugEbene: 2; for Debug Lines from MaterialHolder,
set DebugEbene: 10; for Debug Lines from All.
--]]

local DebugEbene = 0;
local function getmdata(v) v="## "..v..": "; for i=1,table.getn(metadata) do local _,n=string.find(metadata[i],v);if n then return (string.sub (metadata[i], n+1)); end;end;end;
local function Debug(e,s,...) if e <= DebugEbene then print((getmdata("Title")).." v"..(getmdata("Version"))..": "..string.format(s,...)); end; end;
local function L(name) local t = getmdata("Title"); return g_i18n:hasText(t.."_"..name) and g_i18n:getText(t.."_"..name) or name; end

newFillTypes = {};

newFillTypes.version = '1.0.0.1';
newFillTypes.author = 'Blacksheep(RC-Devil)';
newFillTypes.web = 'Web: http://www.farming-mods.de';
newFillTypes.date = '13 March 2017';
local modDir = g_currentModDirectory;

local nStarts, nEnds = string.find(modDir,"placeable");
if nStarts then
function newFillTypes:start(modDir)
	 if self.initialized then
	    return 
	 end;
	local modDir = g_currentModDirectory;
	local xmlFilePath =  Utils.getFilename('modDesc.xml', modDir);
	if fileExists(xmlFilePath) then
		local xmlFile = loadXMLFile('modDescXML', xmlFilePath);
		local key = 'modDesc.newFillTypes';
		if hasXMLProperty(xmlFile, key) then
			local hudsDir = getXMLString(xmlFile, key..'#hudsDirectory');
			local groundTipDir = getXMLString(xmlFile, key..'#groundTipDirectory');
			local materialDir = getXMLString(xmlFile, key..'#materialDirectory');
			local hasHolders = getXMLString(xmlFile, key..'#hasHolders');
			if hudsDir ~= nil or groundTipDir ~= nil or materialDir ~= nil then
            if hudsDir:sub(-1) ~= '/' then
               hudsDir = hudsDir .. '/';
            end;
               hudsDir = modDir .. hudsDir;
            if groundTipDir:sub(-1) ~= '/' then
            groundTipDir = groundTipDir .. '/';
         end;
            groundTipDir = modDir .. groundTipDir;
			if materialDir:sub(-1) ~= '/' then
            materialDir = materialDir .. '/';
         end;
            materialDir = modDir .. materialDir;
		    self:registerFillTypes(xmlFile, key, hudsDir, groundTipDir, materialDir, hasHolders);
      else
         if hudsDir == nil then print('\\__ Error: newFillTypes could not find Huds Directory.');end;
         if groundTipDir == nil then print('\\__ Error: newFillTypes could not find GroundTip Directory.');end;
		 if materialDir == nil then print('\\__ Error: newFillTypes could not find Material Directory.');end;
      end;
			Debug(-1,('\\__ newFillTypes V%s by %s from %s was loaded successful, Support over %s'):format(newFillTypes.version, newFillTypes.author, newFillTypes.date, newFillTypes.web));
		end; 
		delete(xmlFile);
	end;
	 self.initialized = true;
end;

function newFillTypes:registerFillTypes(xmlFile, key, hudsDir, groundTipDir, materialDir, hasHolders)
    Debug(-1,('\\__ newFillTypes V%s by %s from %s is loading Support over %s'):format(newFillTypes.version, newFillTypes.author, newFillTypes.date, newFillTypes.web));
    -- FILLTYPES --
	local a = 0
	while true do
		local fillTypeKey = key .. ('.fillType(%d)'):format(a);
		if not hasXMLProperty(xmlFile, fillTypeKey) then
		    break;
		end;
		local name = getXMLString(xmlFile, fillTypeKey..'#name');
		if name == nil then
			print(('\\__ Error: missing "name" attribute for fillType #%d in "newFillTypes". Adding fillTypes aborted.'):format(a));
			break;
		end;
		local gameKey = 'FILLTYPE_' .. name:upper();
		if FillUtil[gameKey] == nil then
			local fillType = {
				name = name,
				pricePerLiter =            Utils.getNoNil(getXMLFloat(xmlFile, fillTypeKey..'#pricePerLiter'), 0.8),
				showOnPriceTable =         Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#showOnPriceTable'), false),
				litersPerSecond =          Utils.round(Utils.getNoNil(getXMLFloat(xmlFile, fillTypeKey..'#litersPerSecond'), 0.0081), 3),
				massPerLiter = 			 Utils.getNoNil(getXMLFloat(xmlFile, fillTypeKey..'#massPerLiter'), 350),
				maxPhysicalSurfaceAngle =  Utils.getNoNil(getXMLFloat(xmlFile, fillTypeKey..'#maxPhysicalSurfaceAngle'), math.rad(20)),				  
				useForSpray =              Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#useForSpray'), false),
				sprayerCategorys =         Utils.getNoNil(getXMLString(xmlFile, fillTypeKey..'#sprayerCategorys'), 'spreader'),
				toCategorys =              Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#toCategorys'), false),
				fillTypeCategorys =        Utils.getNoNil(getXMLString(xmlFile, fillTypeKey..'#fillTypeCategorys'), 'bulk'),
				hasHolders =               Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#hasHolders'), false),
				hasMaterials =             Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#hasMaterials'), false),
				hasParticles =             Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#hasParticles'), false),
				useHeap =            	     Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#useHeap'), false),
				isCowBasefeed =            Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isCowBasefeed'), false),
				isCowGrass =            	 Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isCowGrass'), false),
				isCowPower =            	 Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isCowPower'), false),
				isCowWindrow =             Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isCowWindrow'), false),
				isCowLiquid =            	 Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isCowLiquid'), false),
				isSheepGrass =             Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isSheepGrass'), false),
				isSheepLiquid =            Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isSheepLiquid'), false),
				isPigBasefeed =            Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isPigBasefeed'), false),
				isPigGrain =            	 Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isPigGrain'), false),
				isPigProtein =             Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isPigProtein'), false),
				isPigEarthfruit =          Utils.getNoNil(getXMLBool(xmlFile, fillTypeKey..'#isPigEarthfruit'), false)
				};
			local localName = fillType.name;
			if g_i18n:hasText(fillType.name) then
				localName = g_i18n:getText(fillType.name);
				g_i18n.globalI18N.texts[fillType.name] = localName;
			end;
			    Debug(1,('\\_ FillType %s Debug Start'):format(fillType.name));
			local fhudFile = ('%shud_fill_%s.dds'):format(hudsDir, fillType.name);
			local fhudFile_small = ('%shud_fill_%s_small.dds'):format(hudsDir, fillType.name);
			if not fileExists(Utils.getFilename(fhudFile_small, self.modDir)) then
			  	print("\\__ "..fhudFile_small.." These are *not* 100%, please check your huds directory or your hud file");
				fhudFile_small = fhudFile;
			end;
			local key = FillUtil.registerFillType(fillType.name, localName, 0, fillType.pricePerLiter, fillType.showOnPriceTable, ('%shud_fill_%s.dds'):format(hudsDir, fillType.name), ('%shud_fill_%s_small.dds'):format(hudsDir, fillType.name), fillType.massPerLiter * 0.000001* 0.5, fillType.maxPhysicalSurfaceAngle);
			if key ~= nil then
			    Debug(1,('\\__ Register FillType: %s (%s) [key %s]'):format(localName, fillType.name, tostring(key)));
				local fillInKey = 'FILLTYPE_' .. string.upper(fillType.name);
			    FillUtil.fillTypeIndexToDesc[FillUtil[fillInKey]].pricePerLiter = fillType.pricePerLiter;
			    Debug(1,('\\_______ FillType %s (%s) [Base-Price %s]'):format(localName, fillType.name, fillType.pricePerLiter));
			end;
			-- Add FillTypes to FillType Category --			  
			if fillType.useForSpray then
			    local spTypeKey = "SPRAYTYPE_" .. string.upper(fillType.name);
				if Sprayer[spTypeKey] == nil then
				    Sprayer.registerSprayType(fillType.name, localName, nil, fillType.pricePerLiter, fillType.litersPerSecond, fillType.showOnPriceTable, ('%shud_fill_%s.dds'):format(hudsDir, fillType.name), ('%shud_fill_%s_small.dds'):format(hudsDir, fillType.name), fillType.massPerLiter);
				    Debug(1,('\\__ Register SprayType: %s (%s)'):format(localName, fillType.name));
				else
					print('\\__ Error: SprayType %s (%s), already exists. "newFillTypes", will skip this registration.'):format(localName, fillType.name);
				end;
				local sprayerCategorys = Utils.splitString(" ", fillType.sprayerCategorys);				
				for _, sprayerCategory in pairs(sprayerCategorys) do
				    sprayCat = "FILLTYPE_CATEGORY_" .. string.upper(sprayerCategory);				
				    if FillUtil[sprayCat] then
					    FillUtil.addFillTypeToCategory(FillUtil[sprayCat], FillUtil[gameKey]);
					    Debug(1,('\\_______ Added SprayType: %s (%s) to %s Category'):format(localName, fillType.name, sprayerCategory));
				    else
					    print('\\_______ ERROR: The Sprayercategory: %s are not exists!. "newFillTypes" will Aborting adding the Spraytype to the specified category!'):format(sprayerCategory);
			        end;
				end;
			  end;
			if fillType.toCategorys then
			    local fillTypeCategorys = Utils.splitString(" ", fillType.fillTypeCategorys);
				for _, fillTypeCategory in pairs(fillTypeCategorys) do
				    typeCat = "FILLTYPE_CATEGORY_" .. string.upper(fillTypeCategory);
				    if FillUtil[typeCat] then
				       FillUtil.addFillTypeToCategory(FillUtil[typeCat], FillUtil[gameKey]);
				       Debug(1,('\\_______ Added FillType: %s (%s) to %s Category'):format(localName, fillType.name, fillTypeCategory));
				    else
				       print('\\_______ ERROR: The FillTypecategory: %s are not exists!. "newFillTypes" will Aborting adding the FillType to the specified category!'):format(fillTypeCategory);
				    end;
				end;
			end;
	        -- Register MaterialType --
			    local ftmt = "FILLTYPE_"..string.upper(fillType.name);
			if fillType.hasMaterials and key ~= nil then
			    local key = MaterialUtil.registerMaterialType(FillUtil[ftmt]);
			    Debug(1,('\\_____ Register Materials for FillType: %s (%s)'):format(localName, fillType.name));
			end;
			-- Register Particles --
			if fillType.hasParticles and key ~= nil then
			    local key = MaterialUtil.registerParticleType(FillUtil[ftmt]);
			    Debug(1,('\\_____ Register Particles for FillType: %s (%s)'):format(localName, fillType.name));
			end;
			-- Tip to Ground DensityMap for FillTypes--
			if fillType.useHeap and key ~= nil then
			    local tipgDiff = ('%s%s_diffuse.dds'):format(groundTipDir, fillType.name);
			    local tipgNorm = ('%s%s_normal.dds'):format(groundTipDir, fillType.name);
			    local tipgDist = ('%s%sDistance_diffuse.dds'):format(groundTipDir, fillType.name);
			if not fileExists(Utils.getFilename(tipgDiff, self.modDir)) then
			  	print("\\__ "..tipgDiff.." not found. Please Check the Directory and File");
			end;
			if not fileExists(Utils.getFilename(tipgNorm, self.modDir)) then
			    Debug(-1,"\\__ "..tipgNorm.." not found. Please Check the Directory and File");
			end;
			if not fileExists(Utils.getFilename(tipgDist, self.modDir)) then
			    print("\\__ "..tipgDist.." not found. Please Check the Directory and File");
			end;
    		local fillsKey = 'FILLTYPE_' .. name:upper();
			    TipUtil.registerDensityMapHeightType(FillUtil[fillsKey], math.rad(30), 1.0, 0.08, 0.00, 0.08, 1, false, tipgDiff, tipgNorm, tipgDist);
				Debug(1,('\\_____ Register TipOnGround DensityMapHeightType: %s (%s)'):format(localName, fillType.name));
				Debug(1,("\\_____ Registered DensityMapHeightType Key: [%s]"):format(TipUtil.NUM_HEIGHTTYPES));
			end;
			--Register FillTypes at Food Groups for Animals			
			 --Cow Groups Index 1
			if fillType.isCowBasefeed ~= false and key ~= nil then
				local key = FillUtil.registerFillTypeInFoodGroup(AnimalUtil.ANIMAL_COW, 2, key);
				Debug(1,('\\_____ Register FillType: %s (%s) to Basefood for Cows'):format(localName, fillType.name));
            end;
			if fillType.isCowGrass ~= false and key ~= nil then
				local key = FillUtil.registerFillTypeInFoodGroup(AnimalUtil.ANIMAL_COW, 1, key);
				Debug(1,('\\_____ Register FillType: %s (%s) as Grass for Cows'):format(localName, fillType.name));
            end;
			if fillType.isCowPower ~= false and key ~= nil then
				local key = FillUtil.registerFillTypeInFoodGroup(AnimalUtil.ANIMAL_COW, 3, key);
				Debug(1,('\\_____ Register FillType: %s (%s) to Powerfood for Cows'):format(localName, fillType.name));
            end;
			 -- Sheep Groups Index 2
			if fillType.isSheepGrass ~= false and key ~= nil then
				local key = FillUtil.registerFillTypeInFoodGroup(AnimalUtil.ANIMAL_SHEEP, 1, key);
				Debug(1,('\\_____ Register FillType: %s (%s) as Grass for Sheeps'):format(localName, fillType.name));
            end;
			 -- Pig Groups Index 3
			if fillType.isPigBasefeed ~= false and key ~= nil then
				local key = FillUtil.registerFillTypeInFoodGroup(AnimalUtil.ANIMAL_PIG, 1, key);
				Debug(1,('\\_____ Register FillType: %s (%s) to Basefood for Pigs'):format(localName, fillType.name));
            end;
			if fillType.isPigGrain ~= false and key ~= nil then
				local key = FillUtil.registerFillTypeInFoodGroup(AnimalUtil.ANIMAL_PIG, 2, key);
				Debug(1,('\\_____ Register FillType: %s (%s) to Grainfood for Pigs'):format(localName, fillType.name));
            end;
			if fillType.isPigProtein ~= false and key ~= nil then
				local key = FillUtil.registerFillTypeInFoodGroup(AnimalUtil.ANIMAL_PIG, 3, key);
				Debug(1,('\\_____ Register FillType: %s (%s) to Proteinfood for Pigs'):format(localName, fillType.name));
            end;
			if fillType.isPigEarthfruit ~= false and key ~= nil then
				local key = FillUtil.registerFillTypeInFoodGroup(AnimalUtil.ANIMAL_PIG, 4, key);
				Debug(1,('\\_____ Register FillType: %s (%s) as Earthfruit for Pigs'):format(localName, fillType.name));
            end;
			 -- If Register any Type for Chickens, then is the Index AnimalUtil.ANIMAL_CHICKEN
			 -- Register FillTypes at Food Groups for Animals End
			Debug(1,('\\_ FillType %s Debug Ende'):format(fillType.name));
			Debug(1,'\\___________________________________________________________________________________________'); 
			a = a + 1
		else
			a = a + 1
			print(('\\__ Error: fill type %q already exists. "newFillTypes" will skip its registration.'):format(name));
		 end;
    end;
	--MaterialHolders
	if hasHolders then
		Debug(2,('\\_ MaterialHolder Debug Start'));
		loadI3DFile(materialDir .. 'materialHolder.i3d');
		Debug(2,('\\_____ MaterialHolder Directory %s loaded'):format(materialDir .. 'materialHolder.i3d'));
		Debug(2,('\\_ MaterialHolder Debug Ende'));
		Debug(2,'\\___________________________________________________________________________________________'); 
	end;
end;
	
newFillTypes:start(modDir);
else
	print("[INFORMATION! ---- The newFillTypes Script is only for Placeable Mods allowed, the Script is Only for Used in Placeable Mods! ----]")
end;
