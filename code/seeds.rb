drugs = YAML::load_file(Rails.root.join("db/drugs.yml"))

drugCategories = {}
drugParts = {}

drugID = 1
drugPartID = 1
drugCategoryID = 1
drugNames = {}
drugs[0,100].each do |drug|
	#имена
	uniq_name = drug["Международное наименование"]
	next unless uniq_name
	english_name = uniq_name.match(/\((.*)\)/)[1]
	drug_in_base = Drug.for(drugID); drugID += 1
	drug_in_base.intern_title = english_name
	drug_in_base.brandName = drug["Торговое наименование"]

	drugNames[drug["Торговое наименование"]] = drugID

	#группа
	groupName = drug["Групповая принадлежность"]
	if groupName
		if drugCategories[groupName]
			drugCategory = DrugCategory.for(drugCategories[groupName])
		else
			drugCategory = DrugCategory.for(drugCategoryID)
			drugCategories[drug["Групповая принадлежность"]] = drugCategoryID
			drugCategoryID += 1
		end
		drugCategory.name = groupName
		drugCategory.save!
		drug_in_base.drugCategories.merge([drugCategory])
	end

	#ингридиенты
	drugPartName = drug["Описание действующего вещества"]
	if drugPartName 
		if drugParts[drugPartName]
			drugPart = DrugPart.for(drugParts[drugPartName])
		else
			drugPart = DrugPart.for(drugPartID)
			drugParts[drug["Описание действующего вещества"]] = drugPartID
			drugPartID += 1
		end
		drugPart.name = drugPartName
		drugPart.save!
		drug_in_base.drugParts.merge([drugPart])
	end
	if drug["Лекарственная форма"]
		drug_in_base.dosageForms.merge(drug["Лекарственная форма"].split(",")) 
	end
	drug_in_base.pharmacology = drug["Фармакологическое действие"]
	if drug["Показания"]
		drug_in_base.indications.merge(drug["Показания"].split(",")) 
	end
	if drug["Противопоказания"]
		drug_in_base.contraindications
			.merge(drug["Противопоказания"].split(/[\,\.]/)) 
	end
	if drug["Побочные действия"]
		drug_in_base.sideEffects.merge(drug["Побочные действия"].split(","))
	end
	drug_in_base.dosage = drug["Способ применения и дозы"]


	drug_in_base.save!
end

drugID = 1
drugInteractionId = 1
drugs[0,100].each do |drug|
	vz = drug["Взаимодействие:"]
	next unless vz
	vz = vz.split(".")
	drugNames.each do |name, id|
		vz.each do |text|
			if text[name]
				di = DrugInteraction.for(drugInteractionId)
				di.drug = Drug.for(id)
				di.description = text
				di.save!
				drug.interactions.merge(di)
				drug.save! 
				drugInteractionId += 1
			end
		end
	end
	drugID += 1
end 