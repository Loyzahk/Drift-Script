-- https://runtime.fivem.net/doc/natives/?_0x29439776AAA00A62
local vehicleClassWhitelist = {0, 1, 2, 3, 4, 5, 6, 7, 9}

local handleMods = {
	{"fInitialDragCoeff", 90.22},
	{"fDriveInertia", .31},
	{"fSteeringLock", 22},
	{"fTractionCurveMax", -1.1},
	{"fTractionCurveMin", -.4},
	{"fTractionCurveLateral", 2.5},
	{"fLowSpeedTractionLossMult", -.57}
}

local ped, vehicle
local driftMode = false

Citizen.CreateThread( function()
	while true do
		Wait(1)
		ped = GetPlayerPed(-1)

		if IsPedInAnyVehicle(ped) then
			tmpvehicle = GetVehiclePedIsIn(ped, false)
			-- Make sure drift mode is deactivated if a new vehicle is used
			if not(vehicle == tmpvehicle) then
				driftMode = false
				vehicle = tmpvehicle
			end
			if (GetPedInVehicleSeat(vehicle, -1) == ped) and IsVehicleOnAllWheels(vehicle) and IsControlJustReleased(0, 21) and IsVehicleClassWhitelisted(GetVehicleClass(vehicle)) then
				if driftMode then
					DriftOff()
				else
					DriftOn()
				end
				driftMode = not(driftMode)
			end
		end
	end
end)

function DriftOff()
	for index, value in ipairs(handleMods) do
		SetVehicleHandlingFloat(vehicle, "CHandlingData", value[1], GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1])-value[2])
	end
	SetVehicleEnginePowerMultiplier(vehicle, 0.0)

	PrintDebugInfo("stock")
	DrawNotif("~y~TCS~s~, ~y~ABS~s~, ~y~ESP ~s~is ~g~on~s~!\nVehicle is in standard mode!")
end

function DriftOn()
	for index, value in ipairs(handleMods) do
		SetVehicleHandlingFloat(vehicle, "CHandlingData", value[1], GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1])+value[2])
	end
	if GetHandlingfDriveBiasFront == 0.0 then
		SetVehicleEnginePowerMultiplier(vehicle, 190.0)
	else
		SetVehicleEnginePowerMultiplier(vehicle, 100.0)
	end

	PrintDebugInfo("drift")
	DrawNotif("~y~TCS~s~, ~y~ABS~s~, ~y~ESP ~s~is ~r~OFF~s~!\nEnjoy driving sideways!")
end

function DrawNotif(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function PrintDebugInfo(mode)
	print(mode)
	for index, value in ipairs(handleMods) do
		print(GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1]))
	end
end

function IsVehicleClassWhitelisted(vehicleClass)
	for index, value in ipairs(vehicleClassWhitelist) do
		if value == vehicleClass then
			return true
		end
	end

	return false
end
