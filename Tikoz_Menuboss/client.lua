ESX = exports["es_extended"]:getSharedObject()

function Keyboardput(TextEntry, ExampleText, MaxStringLength) 
    AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
    blockinput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

function depotargent()
    local amount = Keyboardput("Combien voulez-vous déposer ? ", "", 25)
    amount = tonumber(amount)
    if amount == nil then
        ESX.ShowAdvancedNotification('Banque societé', "~b~"..ESX.PlayerData.job.label, "Vous avez pas assez ~r~d'argent", 'CHAR_BANK_FLEECA', 9)
    else
        TriggerServerEvent("Tikoz/Alldepotentreprise", amount)
    end
end

function retraitargent()
    local amount = Keyboardput("Combien voulez-vous retirer ? ", "", 25)
    amount = tonumber(amount)
    if amount == nil then
        ESX.ShowAdvancedNotification('Banque societé', "~b~"..ESX.PlayerData.job.label, "Vous avez pas assez ~r~d'argent", 'CHAR_BANK_FLEECA', 9)
    else
        TriggerServerEvent("Tikoz/AllRetraitEntreprise", amount)
    end
end

local function menuselected(self, _, btn, PMenu, menuData, result)

    ESX.TriggerServerCallback("Tikoz/AllArgentEntreprise", function(compteentreprise) 
        if btn.name == "Compte en banque" then
            for i=1, #compteentreprise, 1 do 
                menu.Menu["Compte en banque"].b = {}
                table.insert(menu.Menu["Compte en banque"].b, { name = "Déposé de l'argent", ask = "", askX = true, Description = "Vous pouvez ~g~déposer ~s~de l'argent dans la ~b~socièté"})
                table.insert(menu.Menu["Compte en banque"].b, { name = "Retiré de l'argent", ask = "", askX = true, Description = "Vous pouvez ~r~retirer ~s~de l'argent dans la ~b~socièté"})
                table.insert(menu.Menu["Compte en banque"].b, { name = "~b~Compte bancaire ~s~:", ask = "~g~"..compteentreprise[i].money.."$", askX = true, Description = "Vous avez ~g~"..compteentreprise[i].money.."$~s~ dans votre ~b~socièté"})
            end
            OpenMenu('Compte en banque')
        end
    end, ESX.PlayerData.job.name)

    if btn.name == "Déposé de l'argent" then
        depotargent()
        OpenMenu('Menu :')
    elseif btn.name == "Retiré de l'argent" then
        retraitargent()
        OpenMenu('Menu :')
    end

    ESX.TriggerServerCallback('Tikoz/AllSalaire', function(salairetaxi) 
        if btn.name == "Salaire employé" then
            menu.Menu["Salaire"].b = {}
            for i=1, #salairetaxi, 1 do
                if salairetaxi[i].job_name == ESX.PlayerData.job.name then
                    table.insert(menu.Menu["Salaire"].b, { name = salairetaxi[i].label, ask = "~g~"..salairetaxi[i].salary.."$", askX = true})
                end
            end
            OpenMenu('Salaire')
        end

        for i=1, #salairetaxi, 1 do
            if btn.name == salairetaxi[i].label then
                if salairetaxi[i].job_name == ESX.PlayerData.job.name then
                    local amount = Keyboardput("Quelle est le nouveau salaire ? ", "", 15)
                    local label = salairetaxi[i].label
                    local id = salairetaxi[i].id
                    TriggerServerEvent('Tikoz/AllNouveauSalaire', id, label, amount)
                    OpenMenu("Menu :")
                    return
                end
            end
        end
    end)

    ESX.TriggerServerCallback("Tikoz/getuser", function(list) 
        ESX.TriggerServerCallback("Tikoz/getjobgrade", function(jb) 
            if (btn.name == "Liste des employés") then
                menu.Menu["Liste des employés"].b = {}
                for i=1, #list, 1 do 
                    for k, v in pairs(jb) do 
                        if v.grade == list[i].job_grade then
                            if ESX.PlayerData.job.name == list[i].job then
                                table.insert(menu.Menu["Liste des employés"].b, {name = list[i].firstname.." "..list[i].lastname, ask = "~b~"..v.label, askX = true})
                                OpenMenu("Liste des employés")
                            end
                        end
                    end
                end
            end

            for i=1, #list, 1 do 
                if (btn.name == list[i].firstname.." "..list[i].lastname) then
                    menu.Menu["Détails"].b = {}
                    for k, v in pairs(jb) do 
                        if v.job_name == list[i].job then
                            if v.grade == list[i].job_grade then
                                iden = list[i].identifier
                                table.insert(menu.Menu["Détails"].b, {name = "Nom et prénom :", ask = "~b~"..list[i].firstname.." "..list[i].lastname, askX = true})
                                table.insert(menu.Menu["Détails"].b, {name = "Grade :", ask = "~y~"..v.label, askX = true})
                                table.insert(menu.Menu["Détails"].b, {name = "Salaire :", ask = "~g~"..v.salary.."$", askX = true, jobname = v.job_name, grd = v.grade})
                                table.insert(menu.Menu["Détails"].b, {name = "~r~Licensier", ask = "", askX = true})
                            end
                        end
                    end
                    OpenMenu("Détails")
                end
            end

            if (btn.name == "Salaire :") then
                local amount = Keyboardput("Quel est le nouveau salaire ?", "", 10)
                if amount == nil then
                    ESX.ShowNotification("~r~Montant invalide")
                else
                    CloseMenu()
                    TriggerServerEvent("Tikoz/updsalarybossmenu", amount, btn.jobname, btn.grd)
                end
            end

            if (btn.name == "Grade :") then
                menu.Menu["Quel grade voulez-vous attribuer ?"].b = {}
                for i=1, #jb, 1 do 
                    table.insert(menu.Menu["Quel grade voulez-vous attribuer ?"].b, {name = "~s~"..jb[i].label, ask = "", askX = true, grd = jb[i].grade})
                end 
                OpenMenu("Quel grade voulez-vous attribuer ?")
            end

            for i=1, #jb, 1 do 
                if (btn.name == "~s~"..jb[i].label) then   
                    CloseMenu()
                    TriggerServerEvent("Tikoz/setjobbossmenu", "upt", jb[i].job_name, btn.grd, iden)
                end
            end

            if (btn.name == "~r~Licensier") then
                TriggerServerEvent("Tikoz/setjobbossmenu", "lic", jb[i].job_name, btn.grd, iden)
                CloseMenu()
            end

        end, ESX.PlayerData.job.name)
    end, ESX.PlayerData.job.name)
end

menu = {}
menu.Base = {Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 215, 255}, Title = "Menu patron"}
menu.Data = {currentMenu = 'Menu :'}
menu.Events = {onSelected = menuselected}
menu.Menu = {
    ["Menu :"] = {
        b = {
            {name = "Compte en banque", ask = ">", askX = true, Description = "~b~Accéder à votre compte en banque"},
            {name = "Salaire employé", ask = ">", askX = true},
            {name = "Liste des employés", ask = ">", askX = true},
        }
    },
    ["Compte en banque"] = {
        b = {
        }
    },
    ["Salaire"] = {
        b = {
        }
    },
    ["Liste des employés"] = {
        b = {
        }
    },
    ["Détails"] = {
        b = {
        }
    },
    ["Quel grade voulez-vous attribuer ?"] = {
        b = {
        }
    },
}

CreateThread(function()
    while true do 
        wait = 0
        if posmenu() then
            if IsControlJustPressed(1,51) then
                CreateMenu(menu)
            end
        else
            wait = 1000
        end
        Wait(wait)
    end
end)

function posmenu()
    for k, v in pairs(Listmenu) do 
        if #(GetEntityCoords(PlayerPedId()) - vector3(v.x, v.y, v.z)) <= 2 and ESX.PlayerData.job.name == v.job and ESX.PlayerData.job.grade_name == "boss" then
            ESX.ShowHelpNotification("Appuie sur ~INPUT_CONTEXT~ pour ouvrir le ~b~menu")
            DrawMarker(6, v.x, v.y, v.z, nil, nil, nil, -90, nil, nil, 0.7, 0.7, 0.7, 0, 251, 255, 200, false, true, 2, false, false, false, false)
            return true
        end
    end
end
