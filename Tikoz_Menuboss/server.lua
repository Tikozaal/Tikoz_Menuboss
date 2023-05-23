ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('Tikoz/AllSalaire', function(source, cb)

    local xPlayer = ESX.GetPlayerFromId(source)
    local allsalaire = {}

    MySQL.Async.fetchAll('SELECT * FROM job_grades', {
    }, function(result)
        for i=1, #result, 1 do
            table.insert(allsalaire, {
				id = result[i].id,
                job_name = result[i].job_name,
                label = result[i].label,
                salary = result[i].salary,
            })
        end
        cb(allsalaire)
    end)
end)

RegisterServerEvent("Tikoz/AllNouveauSalaire")
AddEventHandler("Tikoz/AllNouveauSalaire", function(id, label, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    MySQL.Async.fetchAll("UPDATE job_grades SET salary = "..amount.." WHERE id = "..id,
	{
		['@id'] = id,
		['@salary'] = amount
	}, function (rowsChanged)
	end)
end)


ESX.RegisterServerCallback('Tikoz:getSocietyMoney', function(source, cb, societyName)
	if societyName ~= nil then
	  local society = "society_"
	  TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
		cb(account.money)
	  end)
	else
	  cb(0)
	end
end)

ESX.RegisterServerCallback('Tikoz/AllArgentEntreprise', function(source, cb, job)

    local xPlayer = ESX.GetPlayerFromId(source)
    local compteentreprise = {}
    local jobname = 'society_'..job
    MySQL.Async.fetchAll('SELECT * FROM addon_account_data WHERE account_name = ?', {
        jobname
    }, function(result)

        for i=1, #result, 1 do
            table.insert(compteentreprise, {
                account_name = result[i].account_name,
                money = result[i].money,
            })
        end
        cb(compteentreprise)
    end)
end)

RegisterServerEvent("Tikoz/Alldepotentreprise")
AddEventHandler("Tikoz/Alldepotentreprise", function(money)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    TriggerEvent('esx_addonaccount:getSharedAccount', "society_"..xPlayer.getJob().name, function (account)
        if xPlayer.getAccount('bank').money >= money then
            account.addMoney(money)
            xPlayer.removeAccountMoney('bank', money)
            TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque Société', "~b~"..xPlayer.getJob().label, "Vous avez déposé ~g~"..money.." $~s~ dans votre ~b~entreprise", 'CHAR_BANK_FLEECA', 9)
        else
            TriggerClientEvent('esx:showNotification', source, "~r~Vous n'avez pas assez d'argent !")
        end
    end)   
end)

RegisterServerEvent("Tikoz/AllRetraitEntreprise")
AddEventHandler("Tikoz/AllRetraitEntreprise", function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addonaccount:getSharedAccount', "society_"..xPlayer.getJob().name, function (account)
		if account.money >= money then
			account.removeMoney(money)
			xPlayer.addAccountMoney('bank', money)
			TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque Société', "~b~"..xPlayer.getJob().label, "Vous avez retiré ~g~"..money .." $~s~ de votre ~b~entreprise", 'CHAR_BANK_FLEECA', 9)
		else
			TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque Société', "~b~"..xPlayer.getJob().label, "Vous avez pas assez d'argent dans votre ~b~entreprise", 'CHAR_BANK_FLEECA', 9)
		end
	end)
end) 

ESX.RegisterServerCallback('Tikoz/getuser', function(source, cb, job)

    local xPlayer = ESX.GetPlayerFromId(source)
    local compteentreprise = {}
    local jobname = 'society_'..job
    MySQL.Async.fetchAll('SELECT * FROM users WHERE job = ?', {
        job
    }, function(result)
        for i=1, #result, 1 do
            table.insert(compteentreprise, {
                identifier = result[i].identifier,
                job = result[i].job,
                job_grade = result[i].job_grade,
                firstname = result[i].firstname,
                lastname = result[i].lastname,
            })
        end
        cb(compteentreprise)
    end)
end)

ESX.RegisterServerCallback('Tikoz/getjobgrade', function(source, cb, job)

    local xPlayer = ESX.GetPlayerFromId(source)
    local jb = {}
    MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = ?', {
        job
    }, function(result)
        for i=1, #result, 1 do
            table.insert(jb, {
                id = result[i].id,
                job_name = result[i].job_name,
                grade = result[i].grade,
                name = result[i].name,
                label = result[i].label,
                salary = result[i].salary,
            })
        end
        cb(jb)
    end)
end)

RegisterServerEvent("Tikoz/setjobbossmenu")
AddEventHandler("Tikoz/setjobbossmenu", function(state, job, grade, iden)
    local _source = source
    local xPlayer = ESX.GetPlayerFromIdentifier(iden)

    if state == "upt" then
        MySQL.Async.execute("UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?",
	    {job, grade, iden}, function (rowsChanged) end)
        xPlayer.setJob(job, grade)
    elseif state == "lic" then
        MySQL.Async.execute("UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?",
	    {"unemployed", 0, iden}, function (rowsChanged) end)
        xPlayer.setJob("unemployed", 0)
    end
end)

RegisterServerEvent("Tikoz/updsalarybossmenu")
AddEventHandler("Tikoz/updsalarybossmenu", function(salary, job, grade)
    local _source = source
    local xPlayer = ESX.GetPlayerFromIdentifier(iden)
    MySQL.Async.execute("UPDATE job_grades SET salary = ? WHERE job_name = ? AND grade = ?",
	{salary, job, grade}, function (rowsChanged) end)
end)