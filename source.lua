if game.PlaceId == 8343259840 then
	local Success, Error = pcall(function()
		repeat wait() until game:IsLoaded()

		-- #region // No Console Log    
		game:GetService("RunService").RenderStepped:Connect(function()
			for _, Connection in next, getconnections(game:GetService("ScriptContext").Error) do
				Connection:Disable()
			end

			for _, Connection in next, getconnections(game:GetService("LogService").MessageOut) do
				Connection:Disable()
			end
		end)
		-- #endregion

		-- #region // Services

		local Version                           = "FemWare Reborn"

		local game                              = game;
		local GetService                        = game.GetService;

		local Workspace                         = GetService(game, "Workspace");
		local Players                           = GetService(game, "Players");
		local ReplicatedStorage                 = GetService(game, "ReplicatedStorage");
		local StarterGui                        = GetService(game, "StarterGui");

		local LogService                        = GetService(game, "LogService");
		local HttpService                       = GetService(game, "HttpService");
		local ScriptContext                     = GetService(game, "ScriptContext");

		local TextChatService = game:GetService("TextChatService")

		local channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

		-- #endregion

		-- #region // Variables

		local Settings                          = { GunMods = { AutoAllowence = true ,NoRecoil = true, InstantEquip = true, Spread = true, AutoMode = false, SpreadAmount = 0 }, DownedChat = false, KillChat = false, DownedMSG = "IM A FEMALE", KillMSG = "", IsDead = true, AutoPickCash = false, AutoPickTools = false, AutoPickScrap = false, InfiniteStamina = false, NoJumpCooldown = false, NoFailLockpick = false, ShowChatLogs = true, NoFlashbang  = false, NoSmoke = false, UnlockDoorsNearby = false, LockDoorsNearby = false, OpenDoorsNearby = false, NoClip = false, FullBright = false, AirStrafe = false,CamFovToggled = false, CamFov = 70, Zoom = 10, InfinitePepperSpray = false, PepperSprayAura = false, WalkSpeed = {Enabled = false, Amount = 30}, JumpPower = {Enabled = false, Amount = 75}, NoBarbwire = false, NoFallDamage = false, NoRagdoll = false, WatermarkOn = false, ViewModel = { Enabled = false, Viewmodel = { Color = Color3.fromRGB(255, 255, 255), Material = Enum.Material.ForceField }, Melees = { Color = Color3.fromRGB(255, 255, 255), Material = Enum.Material.ForceField }, Guns = { Color = Color3.fromRGB(255, 255, 255), Material = Enum.Material.Plastic }, LeftArmOff = false }, CustomHitSound = 5043539486, VolumeHitsound = 1, WallBang = false, ElevatorTP = false, TowerTP = false, UIKey = Enum.KeyCode.LeftAlt};
		local ESPSettings                       = { PlayerESP = { Enabled = true, TracersOn = false, BoxesOn = false, NamesOn = true, DistanceOn = true, HealthOn = true, ToolOn = true, FaceCamOn = false, Distance = 2000 }, ScrapESP = { Enabled = false, Distance = 2000, LegendaryOnly = true, RareOnly = true, GoodOnly = true, BadOnly = true }, SafeESP = { Enabled = false, Distance = 2000, BigOnly = true, SmallOnly = true }, RegisterESP = { Enabled = false, Distance = 2000 }, ESPColor = Color3.fromRGB(255, 255, 255), ToolColor = Color3.fromRGB(255, 255, 255)};
		local CoolDowns                         = { AutoPickUps = { MoneyCooldown = false, ScrapCooldown = false, ToolCooldown = false } }

		-- #region Silent Aim
		local SilentSettings                    = { Main = { Enabled = true, TeamCheck = false, VisibleCheck = false, TargetPart = "Head" }, FOVSettings = { Visible = false, Radius = 360 }, SilentAimColor = Color3.fromRGB(255, 255, 255)};
		local ValidTargetParts                  = {"Head", "Torso", "Random"};

		local Player                            = Players.LocalPlayer;
		local Character                         = Player.Character or Player.CharacterAdded:Wait();
		local Mouse                             = Player:GetMouse()
		local Cam                               = workspace.CurrentCamera;

		local WorldToScreen                     = Cam.WorldToScreenPoint
		local WorldToViewportPoint              = Cam.WorldToViewportPoint
		local GetPartsObscuringTarget           = Cam.GetPartsObscuringTarget

		local RequiredArgs = {
			ArgCountRequired = 3,
			Args = {
				"Instance", "Vector3", "Vector3", "RaycastParams"
			}
		}
		-- #endregion

		-- #region Silent Aim Functions
		local function GetPositionOnScreen(Vector)
			local Vec3, OnScreen = WorldToScreen(Cam, Vector)
			return Vector2.new(Vec3.X, Vec3.Y), OnScreen
		end

		local function ValidateArguments(Args, RayMethod)
			local Matches = 0

			if #Args < RayMethod.ArgCountRequired then
				return false
			end

			for Pos, Argument in next, Args do
				if typeof(Argument) == RayMethod.Args[Pos] then
					Matches = Matches + 1
				end
			end

			return Matches >= RayMethod.ArgCountRequired
		end

		local function GetDirection(Origin, Position)
			return (Position - Origin).Unit * 1000
		end

		local function GetMousePosition()
			return Vector2.new(Mouse.X, Mouse.Y)
		end

		local function IsPlayerVisible(TargetPlayer)
			local PlayerCharacter = TargetPlayer.Character
			local LocalPlayerCharacter = Player.Character

			if not (PlayerCharacter or LocalPlayerCharacter) then return end 

			local PlayerRoot = game.FindFirstChild(PlayerCharacter, SilentSettings.Main.TargetPart) or game.FindFirstChild(PlayerCharacter, "HumanoidRootPart")

			if not PlayerRoot then return end 

			local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
			local ObscuringObjects = #GetPartsObscuringTarget(Cam, CastPoints, IgnoreList)

			return ((ObscuringObjects == 0 and true) or (ObscuringObjects > 0 and false))
		end

		local function GetClosestPlayer()
			if not SilentSettings.Main.TargetPart then return end

			local Closest
			local DistanceToMouse

			for _, v in next, game.GetChildren(Players) do
				if v == Player then continue end
				if SilentSettings.Main.TeamCheck and v.Team == Player.Team then continue end

				local Character = v.Character
				if not Character then continue end

				--if SilentSettings.Main.VisibleCheck and not IsPlayerVisible(v) then continue end

				local HumanoidRootPart = game.FindFirstChild(Character, "HumanoidRootPart")
				local Humanoid = game.FindFirstChild(Character, "Humanoid")

				if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end

				local ScreenPosition, OnScreen = GetPositionOnScreen(HumanoidRootPart.Position)

				if not OnScreen then continue end

				local Distance = (GetMousePosition() - ScreenPosition).Magnitude
				if Distance <= (DistanceToMouse or (SilentSettings.Main.Enabled and SilentSettings.FOVSettings.Radius) or 2000) then
					Closest = ((SilentSettings.Main.TargetPart == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]) or Character[SilentSettings.Main.TargetPart])
					DistanceToMouse = Distance
				end
			end
			return Closest
		end
		-- #endregion

		-- #endregion

		-- #region // Esp Handlers

		-- #region // ScrapESP 
		local function ScrapESP(Scrap)
			local ItemName = Drawing.new("Text")
			ItemName.Visible = false
			ItemName.Center = true
			ItemName.Outline = true
			ItemName.Font = 2
			ItemName.Size = 13
			ItemName.Color = Color3.new(1, 2.5, 2.5)
			ItemName.Text = "Scrap"

			local RarityText = Drawing.new("Text")
			RarityText.Visible = false
			RarityText.Center = true
			RarityText.Outline = true
			RarityText.Font = 2
			RarityText.Size = 13
			RarityText.Color = Color3.new(1, 2.5, 2.5)
			RarityText.Text = "Type"

			local DistanceText = Drawing.new("Text")
			DistanceText.Visible = false
			DistanceText.Center = true
			DistanceText.Outline = true
			DistanceText.Font = 2
			DistanceText.Size = 13
			DistanceText.Color = Color3.new(1, 2.5, 2.5)
			DistanceText.Text = "Distance"

			local function InfoUpdate()
				local Iu

				Iu = game:GetService("RunService").RenderStepped:Connect(function()
					if not workspace:IsAncestorOf(Scrap) then
						ItemName.Visible = false
						RarityText.Visible = false
						DistanceText.Visible = false

						Iu:Disconnect()
					else
						local Vector, OnScreen = Cam:WorldToViewportPoint(Scrap:FindFirstChild("MeshPart").Position)

						if OnScreen then
							ItemName.Position = Vector2.new(Vector.X, Vector.Y - 30)
							RarityText.Position = Vector2.new(Vector.X, Vector.Y - 20)
							DistanceText.Position = Vector2.new(Vector.X, Vector.Y - 10)

							ItemName.Visible = false
							RarityText.Visible = false
							DistanceText.Visible = false

							local ItemDistance = math.ceil((Scrap.MeshPart.Position - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude)

							if ESPSettings.ScrapESP.Enabled == true then
								if ItemDistance < ESPSettings.ScrapESP.Distance then
									if tostring(Scrap:FindFirstChild("MeshPart"):FindFirstChild("Particle").Color) == "0 1 1 1 0 1 1 1 1 0 " then
										RarityText.Text = "Rarity: Bad"
										RarityText.Color = Color3.new(1, 2.5, 2.5)

										if ESPSettings.ScrapESP.BadOnly == true then
											ItemName.Visible = true
											RarityText.Visible = true
											DistanceText.Visible = true
										else
											ItemName.Visible = false
											RarityText.Visible = false
											DistanceText.Visible = false
										end
									elseif tostring(Scrap:FindFirstChild("MeshPart"):FindFirstChild("Particle").Color) == "0 0.184314 1 0.4 0 1 0.184314 1 0.4 0 " then
										RarityText.Text = "Rarity: Good"
										RarityText.Color = Color3.new(0, 2.5, 0)

										if ESPSettings.ScrapESP.GoodOnly == true then
											ItemName.Visible = true
											RarityText.Visible = true
											DistanceText.Visible = true
										else
											ItemName.Visible = false
											RarityText.Visible = false
											DistanceText.Visible = false
										end
									elseif tostring(Scrap:FindFirstChild("MeshPart"):FindFirstChild("Particle").Color) == "0 1 0.184314 0.184314 0 1 1 0.184314 0.184314 0 " then
										RarityText.Text = "Rarity: Rare"
										RarityText.Color = Color3.new(1, 0, 0)

										if ESPSettings.ScrapESP.RareOnly == true then
											ItemName.Visible = true
											RarityText.Visible = true
											DistanceText.Visible = true
										else
											ItemName.Visible = false
											RarityText.Visible = false
											DistanceText.Visible = false
										end
									else
										RarityText.Text = "Rarity: Legnedary"
										RarityText.Color = Color3.new(1, 1, 0.5)

										if ESPSettings.ScrapESP.LegendaryOnly == true then
											ItemName.Visible = true
											RarityText.Visible = true
											DistanceText.Visible = true
										else
											ItemName.Visible = false
											RarityText.Visible = false
											DistanceText.Visible = false
										end
									end

									DistanceText.Text = "["..tostring(ItemDistance).."]"
								else
									ItemName.Visible = false
									RarityText.Visible = false
									DistanceText.Visible = false
								end
							else
								ItemName.Visible = false
								RarityText.Visible = false
								DistanceText.Visible = false

								Iu:Disconnect()
							end
						else
							ItemName.Visible = false
							RarityText.Visible = false
							DistanceText.Visible = false
						end
					end
				end)
			end
			coroutine.wrap(InfoUpdate)()
		end
		-- #endregion

		-- #region // SafeESP 
		local function SafeESP(Vault, RarityValue)
			local ItemName = Drawing.new("Text")
			ItemName.Visible = false
			ItemName.Center = true
			ItemName.Outline = true
			ItemName.Font = 2
			ItemName.Size = 13
			ItemName.Color = Color3.new(1, 2.5, 2.5)
			ItemName.Text = "Safe"

			local RarityText = Drawing.new("Text")
			RarityText.Visible = false
			RarityText.Center = true
			RarityText.Outline = true
			RarityText.Font = 2
			RarityText.Size = 13
			RarityText.Color = Color3.new(1, 2.5, 2.5)
			RarityText.Text = "Type"

			-- local StatusText = Drawing.new("Text")
			-- StatusText.Visible = false
			-- StatusText.Center = true
			-- StatusText.Outline = true
			-- StatusText.Font = 2
			-- StatusText.Size = 13
			-- StatusText.Color = Color3.new(1, 2.5, 2.5)
			-- StatusText.Text = "Status"

			local DistanceText = Drawing.new("Text")
			DistanceText.Visible = false
			DistanceText.Center = true
			DistanceText.Outline = true
			DistanceText.Font = 2
			DistanceText.Size = 13
			DistanceText.Color = Color3.new(1, 2.5, 2.5)
			DistanceText.Text = "Distance"

			local function InfoUpdate()
				local Iu

				Iu = game:GetService("RunService").RenderStepped:Connect(function()
					if not workspace:IsAncestorOf(Vault) then
						ItemName.Visible = false
						RarityText.Visible = false
						-- StatusText.Visible = false
						DistanceText.Visible = false

						Iu:Disconnect()
					else
						local Vector, OnScreen = Cam:WorldToViewportPoint(Vault:FindFirstChild("MainPart").Position)

						if OnScreen then
							ItemName.Position = Vector2.new(Vector.X, Vector.Y - 30)
							RarityText.Position = Vector2.new(Vector.X, Vector.Y - 20)
							-- StatusText.Position = Vector2.new(Vector.X, Vector.Y - 20)
							DistanceText.Position = Vector2.new(Vector.X, Vector.Y - 10)

							ItemName.Visible = false
							RarityText.Visible = false
							-- StatusText.Visible = false
							DistanceText.Visible = false

							local ItemDistance = math.ceil((Vault:FindFirstChild("MainPart").Position - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude)

							if ESPSettings.SafeESP.Enabled == true then
								if ItemDistance < ESPSettings.SafeESP.Distance then
									if RarityValue == 2 then
										RarityText.Text = "Rarity: Good"
										RarityText.Color = Color3.new(0, 2.5, 0)

										if ESPSettings.SafeESP.SmallOnly == true then
											ItemName.Visible = true
											RarityText.Visible = true
											-- StatusText.Visible = true
											DistanceText.Visible = true
										else
											ItemName.Visible = false
											RarityText.Visible = false
											-- StatusText.Visible = false
											DistanceText.Visible = false
										end
									elseif RarityValue == 3 then
										RarityText.Text = "Rarity: Rare"
										RarityText.Color = Color3.new(1, 0, 0)

										if ESPSettings.SafeESP.BigOnly == true then
											ItemName.Visible = true
											RarityText.Visible = true
											-- StatusText.Visible = true
											DistanceText.Visible = true
										else
											ItemName.Visible = false
											RarityText.Visible = false
											-- StatusText.Visible = false
											DistanceText.Visible = false
										end
									end

									DistanceText.Text = "["..tostring(ItemDistance).."]"

									if Vault.Values.Broken.Value == false then
										-- StatusText.Text = "NOT BROKEN"

										ItemName.Visible = true
										RarityText.Visible = true
										-- StatusText.Visible = true
										DistanceText.Visible = true

									else
										-- StatusText.Text = "BROKEN"

										ItemName.Visible = false
										RarityText.Visible = false
										-- StatusText.Visible = false
										DistanceText.Visible = false

									end
								else
									ItemName.Visible = false
									RarityText.Visible = false
									-- StatusText.Visible = false
									DistanceText.Visible = false
								end
							else
								ItemName.Visible = false
								RarityText.Visible = false
								-- StatusText.Visible = false
								DistanceText.Visible = false

								Iu:Disconnect()
							end
						else
							ItemName.Visible = false
							RarityText.Visible = false
							-- StatusText.Visible = false
							DistanceText.Visible = false
						end
					end
				end)
			end
			coroutine.wrap(InfoUpdate)()
		end
		-- #endregion

		-- #region // RegisterESP 
		local function RegisterESP(Register)
			local ItemName = Drawing.new("Text")
			ItemName.Visible = false
			ItemName.Center = true
			ItemName.Outline = true
			ItemName.Font = 2
			ItemName.Size = 13
			ItemName.Color = Color3.new(1, 2.5, 2.5)
			ItemName.Text = "Register"

			-- local StatusText = Drawing.new("Text")
			-- StatusText.Visible = false
			-- StatusText.Center = true
			-- StatusText.Outline = true
			-- StatusText.Font = 2
			-- StatusText.Size = 13
			-- StatusText.Color = Color3.new(1, 2.5, 2.5)
			-- StatusText.Text = "Status"

			local DistanceText = Drawing.new("Text")
			DistanceText.Visible = false
			DistanceText.Center = true
			DistanceText.Outline = true
			DistanceText.Font = 2
			DistanceText.Size = 13
			DistanceText.Color = Color3.new(1, 2.5, 2.5)
			DistanceText.Text = "Distance"

			local function InfoUpdate()
				local Iu

				Iu = game:GetService("RunService").RenderStepped:Connect(function()
					if not workspace:IsAncestorOf(Register) then
						ItemName.Visible = false
						-- StatusText.Visible = false
						DistanceText.Visible = false

						Iu:Disconnect()
					else
						local Vector, OnScreen = Cam:WorldToViewportPoint(Register:FindFirstChild("MainPart").Position)

						if OnScreen then
							ItemName.Position = Vector2.new(Vector.X, Vector.Y - 20)
							-- StatusText.Position = Vector2.new(Vector.X, Vector.Y - 20)
							DistanceText.Position = Vector2.new(Vector.X, Vector.Y - 10)

							ItemName.Visible = false
							-- StatusText.Visible = false
							DistanceText.Visible = false

							local ItemDistance = math.ceil((Register:FindFirstChild("MainPart").Position - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude)

							if ESPSettings.RegisterESP.Enabled == true then
								if ItemDistance < ESPSettings.RegisterESP.Distance then
									--ItemName.Visible = true
									-- StatusText.Visible = true
									-- DistanceText.Visible = true

									DistanceText.Text = "["..tostring(ItemDistance).."]"

									if Register.Values.Broken.Value == false then
										-- StatusText.Text = "NOT BROKEN"

										ItemName.Visible = true
										-- StatusText.Visible = true
										DistanceText.Visible = true

									else
										-- StatusText.Text = "BROKEN"

										ItemName.Visible = false
										-- StatusText.Visible = false
										DistanceText.Visible = false

									end
								else
									ItemName.Visible = false
									-- StatusText.Visible = false
									DistanceText.Visible = false
								end
							else
								ItemName.Visible = false
								-- StatusText.Visible = false
								DistanceText.Visible = false

								Iu:Disconnect()
							end
						else
							ItemName.Visible = false
							-- StatusText.Visible = false
							DistanceText.Visible = false
						end
					end
				end)
			end
			coroutine.wrap(InfoUpdate)()
		end
		-- #endregion

		-- #region // Scrap Added
		game:GetService("Workspace").Filter.SpawnedPiles.ChildAdded:Connect(function(Object)
			if ESPSettings.ScrapESP.Enabled == true then
				coroutine.wrap(ScrapESP)(Object)
			end
		end)
		-- #endregion

		-- #endregion

		-- #region // Objects

		--local wlID = loadstring(game:HttpGet("https://raw.githubusercontent.com/poweringc/QContents/main/.getid", true))()

		local Framework                = loadstring(game:HttpGet("https://raw.githubusercontent.com/Byfr0n/FemWareReborn/refs/heads/main/TestUI.lua", true))()
		local ESPFramework             = loadstring(game:HttpGet("https://raw.githubusercontent.com/Byfr0n/FemWareReborn/refs/heads/main/ESP.lua", true))()
		local Watermark                = Framework:CreateWatermark("[R] FemWare | Criminality | {fps}")

		--if wlID[game.Players.LocalPlayer.UserId] then
		--FemWare                  = Framework:CreateWindow(Version, Vector2.new(550, 700)) -- 492, 588
		--else
		local FemWare                  = Framework:CreateWindow(Version, Vector2.new(492, 700)) -- 492, 588
		--end

		local Credits                  = FemWare:CreateTab("Settings")
		-- if wlID[game.Players.LocalPlayer.UserId] then
		-- 	Prem = FemWare:CreateTab("Premium")
		-- 	PremSec = Prem:CreateSector("Something", "right")
		-- 	PremSec:AddSeperator("Coming Soon...")
		-- 	PremSec:AddTextbox("Reason", false, function(V)
		-- 		game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(V`, "All"`)
		-- 	end)
		-- 	PremSec:AddTextbox("Reason", false, function(V)
		-- 		game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(V, "System")
		-- 	end)
		-- end
		local General                  = FemWare:CreateTab("General")
		local Extra                    = FemWare:CreateTab("Extra")
		local Visuals                  = FemWare:CreateTab("Visuals")
		local TeleportsSS              = FemWare:CreateTab("Teleport Area")
		local TeleportsS               = FemWare:CreateTab("Teleports")

		local MainS                    = General:CreateSector("Main", "left")
		local GunModsS                 = General:CreateSector("Gun Mods", "right")
		local PlayerS                  = General:CreateSector("Player Mods", "right")
		local CustomT                  = Extra:CreateSector("Modifications", "left")
		local CustomS                  = Extra:CreateSector("Audio", "right")
		local SilentAimS               = General:CreateSector("Silent Aim", "right")

		local PlayerEspS               = Visuals:CreateSector("Player Visuals", "left")
		local ScrapEspS                = Visuals:CreateSector("Scrap Visuals", "right")
		local SafeEspS                 = Visuals:CreateSector("Safe Visuals", "left")
		local RegisterEspS             = Visuals:CreateSector("Register Visuals", "left")
		local ViewmodelS               = Visuals:CreateSector("Viewmodel", "right")

		local InfoS                    = Credits:CreateSector("Settings", "right")
		local CreditsS                 = Credits:CreateSector("Credits", "left")
		local MiscS                    = Credits:CreateSector("Miscellaneous", "right")
		local ConfigS                  = Credits:CreateConfigSystem("left")

		local TeleportNew1             = TeleportsSS:CreateSector("Locations", "right")
		local TeleportAreas1           = TeleportsS:CreateSector("Locations Inside", "left") 
		local TeleportAreas2           = TeleportsS:CreateSector("Locations Outside", "right") 
		local TeleportAreas3           = TeleportsS:CreateSector("Dealers", "left") 
		local TeleportAreas4           = TeleportsS:CreateSector("ATMs", "right")


		local SilentAIMFov             = Drawing.new("Circle")
		SilentAIMFov.Thickness         = 1
		SilentAIMFov.NumSides          = 100
		SilentAIMFov.Radius            = 360
		SilentAIMFov.Filled            = false
		SilentAIMFov.Visible           = false
		SilentAIMFov.ZIndex            = 999
		SilentAIMFov.Transparency      = 1
		SilentAIMFov.Color             = SilentSettings.SilentAimColor
		SilentSettings.Visible         = false

		-- #endregion

		-- #region // Codes

		game.Players.PlayerAdded:Connect(function(AdminUserCheck)
			if AdminUserCheck.UserId == 68246168 or AdminUserCheck.UserId == 955294 or AdminUserCheck.UserId == 1095419 or AdminUserCheck.UserId == 50585425 or AdminUserCheck.UserId == 48405917 or AdminUserCheck.UserId == 9212846 or AdminUserCheck.UserId == 47352513 or AdminUserCheck.UserId == 48058122 then
				StarterGui:SetCore("SendNotification", {Title = "FemWare"; Text = "Mod Alert\n"..AdminUserCheck.Name..", Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 120 })
			elseif AdminUserCheck.UserId == 42066711 or AdminUserCheck.UserId == 513615792 then
				StarterGui:SetCore("SendNotification", {Title = "FemWare"; Text = "Contractors Alert\n"..AdminUserCheck.Name..", Is in the server"; Icon = "rbxassetid://8426126371"; Duration = 120 })
			elseif AdminUserCheck.UserId == 151691292 or AdminUserCheck.UserId == 92504899 or AdminUserCheck.UserId == 31967243 then
				StarterGui:SetCore("SendNotification", {Title = "FemWare"; Text = "Devs Alert\n"..AdminUserCheck.Name..", Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 120 })
			elseif AdminUserCheck.UserId == 29761878 then
				StarterGui:SetCore("SendNotification", {Title = "FemWare"; Text = "Owner Alert\nRvvz, Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 120 })
			end
		end)

		for i, v in pairs(game.Players:GetPlayers()) do
			if v.UserId == 68246168 or v.UserId == 955294 or v.UserId == 1095419 or v.UserId == 50585425 or v.UserId == 48405917 or v.UserId == 9212846 or v.UserId == 47352513 or v.UserId == 48058122 then
				StarterGui:SetCore("SendNotification", {Title = "FemWare"; Text = "Mod Alert\n"..v.Name..", Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 120 })
			elseif v.UserId == 42066711 or v.UserId == 513615792 then
				StarterGui:SetCore("SendNotification", {Title = "FemWare"; Text = "Contractors Alert\n"..v.Name..", Is in the server"; Icon = "rbxassetid://8426126371"; Duration = 120 })
			elseif v.UserId == 151691292 or v.UserId == 92504899 or v.UserId == 31967243 then
				StarterGui:SetCore("SendNotification", {Title = "FemWare"; Text = "Devs Alert\n"..v.Name..", Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 120 })
			elseif v.UserId == 29761878 then
				StarterGui:SetCore("SendNotification", {Title = "FemWare"; Text = "Owner Alert\nRvvz, Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 120 })
			end
		end
		-- #endregion

		-- #region Infinite Stamina
		local oldStamina
		oldStamina =
			hookfunction(
				getupvalue(getrenv()._G.S_Take, 2),
				function(v1, ...)
					if (Settings.InfiniteStamina) then -- god damn the roblox engine is so shit
						v1 = 0
					end
					return oldStamina(v1, ...)
				end
			)
		-- #endregion

		-- #region No Jump Cooldown
		local mt = getrawmetatable(game)
		setreadonly(mt, false)  -- Allow changes to the metatable

		local original_newindex = mt.__newindex

		mt.__newindex = function(t, k, v)
			if not checkcaller() then  -- Skip game-internal calls
				if t:IsDescendantOf(Character) and k == "Jump" and v == false then
					if Settings.NoJumpCooldown then
						return  -- Skip to prevent cooldown
					end
				end
			end
			return original_newindex(t, k, v)  -- Fallback to original behavior
		end

		setreadonly(mt, true)  -- Restore read-only status
		-- #endregion



		-- #region Auto Pickup
		coroutine.wrap(function()
			game:GetService("RunService").RenderStepped:Connect(function()
				if Settings.AutoPickScrap == true then
					for i, v in pairs(game:GetService("Workspace").Filter.SpawnedPiles:GetChildren()) do
						if Settings.IsDead == false then
							if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v:FindFirstChild("MeshPart").Position).Magnitude < 5 then
								if CoolDowns.AutoPickUps.ScrapCooldown == false then
									CoolDowns.AutoPickUps.ScrapCooldown = true
									game:GetService("ReplicatedStorage").Events.PIC_PU:FireServer(string.reverse(v:GetAttribute("zp")))

									wait(1)

									CoolDowns.AutoPickUps.ScrapCooldown = false
								end
							end
						end 
					end
				end
			end)
		end)()

		coroutine.wrap(function()
			game:GetService("RunService").RenderStepped:Connect(function()
				if Settings.AutoPickTools == true then
					for i, v in pairs(game:GetService("Workspace").Filter.SpawnedTools:GetChildren()) do
						if Settings.IsDead == false then
							if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v:FindFirstChildWhichIsA("MeshPart").Position).Magnitude < 5 then
								if CoolDowns.AutoPickUps.ToolCooldown == false then
									CoolDowns.AutoPickUps.ToolCooldown = true
									game:GetService("ReplicatedStorage").Events.PIC_TLO:FireServer(v:FindFirstChildWhichIsA("MeshPart"))

									wait(1)

									CoolDowns.AutoPickUps.ToolCooldown = false
								end
							end
						end
					end
				end
			end)
		end)()

		coroutine.wrap(function()
			game:GetService("RunService").RenderStepped:Connect(function()
				if Settings.AutoPickCash == true then
					for i, v in pairs(game:GetService("Workspace").Filter.SpawnedBread:GetChildren()) do
						if Settings.IsDead == false then
							if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v.Position).Magnitude < 5 then
								if CoolDowns.AutoPickUps.MoneyCooldown == false then
									CoolDowns.AutoPickUps.MoneyCooldown = true
									game:GetService("ReplicatedStorage").Events.CZDPZUS:FireServer(v)

									wait(1)

									CoolDowns.AutoPickUps.MoneyCooldown = false
								end
							end
						end
					end
				end
			end)
		end)()
		-- #endregion

		-- #region FlashBang
		game.Workspace.Camera.ChildAdded:Connect(function(Item)
			if Settings.NoFlashbang == true then
				if Item.Name == "BlindEffect" then
					Item.Enabled = false
				end
			end
		end)

		game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
			if Item.Name == "FlashedGUI" then
				if Settings.NoFlashbang == true then
					Item.Enabled = false
				end
			end
		end)
		-- #endregion

		-- #region Smoke
		game.Workspace.Debris.ChildAdded:Connect(function(Item)
			if Item.Name == "SmokeExplosion" then
				if Settings.NoSmoke == true then
					wait(0.1)
					Item.Particle1:Destroy()
					Item.Particle2:Destroy()
				end
			end
		end)

		game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
			if Item.Name == "SmokeScreenGUI" then
				if Settings.NoSmoke == true then
					Item.Enabled = false
				end
			end
		end)

		-- #region Pepper Spray Aura
		coroutine.wrap(function()
			game:GetService("RunService").RenderStepped:Connect(function()
				wait(1)

				if Settings.IsDead == false then
					if Player.Character:FindFirstChild("Pepper-spray") then
						if Settings.PepperSprayAura == true then
							if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 15 then
								game.Players.LocalPlayer.Character["Pepper-spray"].RemoteEvent:FireServer("Spray", true)
								game.Players.LocalPlayer.Character["Pepper-spray"].RemoteEvent:FireServer("Hit", v.Character)
							else
								game.Players.LocalPlayer.Character["Pepper-spray"].RemoteEvent:FireServer("Spray", false)
							end
						end
					end
				end
			end)
		end)()
		-- #endregion

		-- #region No Fail Lockpick
		game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
			if Settings.NoFailLockpick == true then
				if Item.Name == "LockpickGUI" then
					Item.MF["LP_Frame"].Frames.B1.Bar.UIScale.Scale = 10
					Item.MF["LP_Frame"].Frames.B2.Bar.UIScale.Scale = 10
					Item.MF["LP_Frame"].Frames.B3.Bar.UIScale.Scale = 10
				end
			elseif Settings.NoFailLockpick == false then
				if Item.Name == "LockpickGUI" then
					Item.MF["LP_Frame"].Frames.B1.Bar.UIScale.Scale = 1
					Item.MF["LP_Frame"].Frames.B2.Bar.UIScale.Scale = 1
					Item.MF["LP_Frame"].Frames.B3.Bar.UIScale.Scale = 1
				end
			end
		end)
		-- #endregion

		-- #region Dead Checker
		game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
			repeat wait() until game.Players.LocalPlayer.Character ~= nil and game.Players.LocalPlayer.Character.Parent ~= nil

			Character = Player.Character
			Settings.IsDead = false

			Character:FindFirstChild("Humanoid").Died:Connect(function()
				if syn then
					if Settings.IsDead == false then
						printconsole("Man died rip 2022 - 2022")

						Settings.IsDead = true 
					end
				else
					if Settings.IsDead == false then
						Settings.IsDead = true 
					end
				end
			end)
		end)

		if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.Parent then
			Settings.IsDead = false
		end
		-- #endregion

		-- #region Chat When Downed
		Player.CharacterAdded:Connect(function()
			local downedStat = game:GetService("ReplicatedStorage").CharStats[Player.Name].Downed
			downedStat.Changed:Connect(function(isDowned)
				if isDowned and Settings.DownedChat then
					channel:SendAsync(Settings.DownedMSG)
				end
			end)
		end)
		-- #endregion


		-- #region Gun Mods
		Player.Character.ChildAdded:Connect(function(Item)
			if Item:IsA("Tool") then
				for i,v in pairs(getgc(true)) do 
					if type(v) == 'table' and rawget(v, 'EquipTime') then 
						if Settings.GunMods.NoRecoil == true then
							v.Recoil = 0
							v.CameraRecoilingEnabled = false
							v.AngleX_Min = 0 
							v.AngleX_Max = 0 
							v.AngleY_Min = 0
							v.AngleY_Max = 0
							v.AngleZ_Min = 0
							v.AngleZ_Max = 0
						end

						if Settings.GunMods.InstantEquip == true then
							v.EquipTime = 0
						end

						if Settings.GunMods.Spread == true then
							v.Spread = Settings.GunMods.SpreadAmount
						end

						if Settings.GunMods.AutoMode == true then
							v.FireModeSettings = {FireMode = "Semi", BurstAmount = 6, BurstRate = 25, CanSwitch = true, SwitchTo = "Auto"}
						end
					end
				end
			end
		end)

		-- Player.Backpack.ChildAdded:Connect(function(Item)
		--     if Item:IsA("Tool") then
		--         for i,v in pairs(getgc(true)) do 
		--             if type(v) == 'table' and rawget(v, 'EquipTime') then 
		--                 if Settings.GunMods.NoRecoil == true then
		--                     v.Recoil = 0
		--                     v.CameraRecoilingEnabled = false
		--                     v.AngleX_Min = 0 
		--                     v.AngleX_Max = 0 
		--                     v.AngleY_Min = 0
		--                     v.AngleY_Max = 0
		--                     v.AngleZ_Min = 0
		--                     v.AngleZ_Max = 0
		--                 end

		--                 if Settings.GunMods.InstantEquip == true then
		--                     v.EquipTime = 0
		--                 end

		--                 if Settings.GunMods.Spread == true then
		--                     v.Spread = Settings.GunMods.SpreadAmount
		--                 end

		--                 if Settings.GunMods.AutoMode == true then
		--                     v.FireModeSettings = {FireMode = "Semi", BurstAmount = 6, BurstRate = 25, CanSwitch = true, SwitchTo = "Auto"}
		--                 end
		--             end
		--         end
		--     end
		-- end)
		-- #endregion

		-- #region Silent Aim

		coroutine.resume(coroutine.create(function()
			game:GetService("RunService").RenderStepped:Connect(function()
				if SilentSettings.FOVSettings.Visible then 
					SilentAIMFov.Visible        = SilentSettings.FOVSettings.Visible
					SilentAIMFov.Color          = SilentSettings.SilentAimColor
					SilentAIMFov.Position       = GetMousePosition() + Vector2.new(0, 36)
				end
			end)
		end))

		local oldNamecall
		oldNamecall = hookmetamethod(game, "__namecall", function(...)
			local Method = getnamecallmethod()
			local Arguments = {...}
			local self = Arguments[1]

			if SilentSettings.Main.Enabled and self == workspace then
				if ValidateArguments(Arguments, RequiredArgs) then
					local A_Origin = Arguments[2]
					local HitPart = GetClosestPlayer()

					if HitPart then
						Arguments[3] = GetDirection(A_Origin, HitPart.Position)

						return oldNamecall(unpack(Arguments))
					end
				end
			end

			return oldNamecall(...)
		end)

		-- #region Anti Stuff

		local oldNamecall
		oldNamecall =
			hookmetamethod(
				game,
				"__namecall",
				newcclosure(
					function(...)
						if (not checkcaller() and getnamecallmethod() == "FireServer" and Settings.NoFallDamage) then
							local tab = ...
							if (tostring(tab) == "__DFfDD") then
								return wait(9e9)
							end
						elseif (not checkcaller() and getnamecallmethod() == "FireServer" and Settings.NoBarbwire) then
							local tab = ...
							if (tostring(tab) == "BHHh") then
								return wait(9e9)
							end
						elseif (not checkcaller() and getnamecallmethod() == "FireServer" and Settings.NoRagdoll) then
							local tab = ...
							if (tostring(tab) == "__--r") then
								return wait(9e9)
							end
						end

						return oldNamecall(...)
					end
				)
			)

		-- #endregion

		-- #region Anti Afk
		local VirtualUser = game:GetService("VirtualUser")

		Player.Idled:connect(function()
			VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
			wait(1)
			VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
		end)
		-- #endregion

		-- #region Viewmodel Visuals
		coroutine.wrap(function()
			game:GetService("RunService").RenderStepped:Connect(function()
				if Settings.IsDead == false then
					if game.Workspace.Camera:FindFirstChild("ViewModel") then
						if Settings.ViewModel.Enabled == true then
							game.Workspace.Camera.ViewModel["Left Arm"].Color = Settings.ViewModel.Viewmodel.Color
							game.Workspace.Camera.ViewModel["Right Arm"].Color = Settings.ViewModel.Viewmodel.Color 

							game.Workspace.Camera.ViewModel["Right Arm"].Material = Settings.ViewModel.Viewmodel.Material
							game.Workspace.Camera.ViewModel["Left Arm"].Material = Settings.ViewModel.Viewmodel.Material

							if Settings.ViewModel.LeftArmOff == true then
								game.Workspace.Camera.ViewModel["Left Arm"].Transparency = 1
							end

							if game.Workspace.Camera.ViewModel:FindFirstChild("Tool") then
								for i,v in pairs(game.Workspace.Camera.ViewModel.Tool:GetDescendants()) do
									if v.Name == "SurfaceAppearance" then
										v:Destroy()
									end
								end
							end

							if game.Workspace.Camera.ViewModel:FindFirstChild("Tool") then
								if game.Workspace.Camera.ViewModel.Tool.Handle:FindFirstChild("Trail") then
									for i, v in pairs(game.Workspace.Camera.ViewModel.Tool:GetDescendants()) do
										if v:IsA("Mesh") or v:IsA("BasePart") or v:IsA("UnionOperation") then
											v.Color = Settings.ViewModel.Melees.Color
											v.Material = Settings.ViewModel.Melees.Material
										end
									end
								else
									for i, v in pairs(game.Workspace.Camera.ViewModel.Tool:GetDescendants()) do
										if v:IsA("Mesh") or v:IsA("BasePart") or v:IsA("UnionOperation") then
											v.Color = Settings.ViewModel.Guns.Color
											v.Material = Settings.ViewModel.Guns.Material
										end
									end
								end
							end
						end
					end
				end
			end)
		end)()
		-- #endregion

		-- #region DealerESP
		ESPFramework:AddObjectListener(workspace.Map.Shopz, {
			Name = "Dealer",
			CustomName = "Dealer",
			Color = Color3.fromRGB(197, 253, 255),
			IsEnabled = "DealerESP"
		})

		ESPFramework:AddObjectListener(workspace.Map.Shopz, {
			Name = "ArmoryDealer",
			CustomName = "Armory Dealer",
			Color = Color3.fromRGB(158, 168, 255),
			IsEnabled = "ArmoryDealerESP"
		})
		-- #endregion

		-- #region AtmESP
		ESPFramework:AddObjectListener(workspace.Map.ATMz, {
			Name = "ATM",
			CustomName = "ATM",
			Color = Color3.fromRGB(197, 255, 120),
			IsEnabled = "AtmESP"
		})

		-- #endregion

		AutoClaimAllowanceCoolDown = false

		function GetATM(Studs)
			if not Studs then return nil end -- Ensure Studs is valid

			local Part
			for _, v in ipairs(game:GetService("Workspace").Map.ATMz:GetChildren()) do
				if v:FindFirstChild("MainPart") then
					local Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position 
						- v:FindFirstChild("MainPart").Position).Magnitude
					if Studs == nil or Distance < Studs then -- Ensure Studs is not nil
						Studs = Distance
						Part = v:FindFirstChild("MainPart")
					end
				end
			end
			return Part
		end


		game:GetService("RunService").RenderStepped:Connect(function(deltaTime)

			if Settings.NoClip == true then
				wait(0.1)
				for _, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
					if v:FindFirstChild("DoorBase") then
						v.DoorBase.CanCollide = false
					end
					if v:FindFirstChild("DoorA") then
						v.DoorA.CanCollide = false
					end
					if v:FindFirstChild("DoorB") then
						v.DoorB.CanCollide = false
					end
					if v:FindFirstChild("DoorC") then
						v.DoorC.CanCollide = false
					end
					if v:FindFirstChild("DoorD") then
						v.DoorD.CanCollide = false
					end
				end
			else
				wait(0.1)
				for _, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
					if v:FindFirstChild("DoorBase") then
						v.DoorBase.CanCollide = true
					end
					if v:FindFirstChild("DoorA") then
						v.DoorA.CanCollide = true
					end
					if v:FindFirstChild("DoorB") then
						v.DoorB.CanCollide = true
					end
					if v:FindFirstChild("DoorC") then
						v.DoorC.CanCollide = true
					end
					if v:FindFirstChild("DoorD") then
						v.DoorD.CanCollide = true
					end
				end
			end

			if Settings.CamFovToggled == true then
				game.Workspace.Camera.FieldOfView = Settings.CamFov
			end
			local strafeDirection = 1

			local player = Players.LocalPlayer
			local character = player.Character or player.CharacterAdded:Wait()
			local humanoid = character:WaitForChild("Humanoid")
			local hrp = character:WaitForChild("HumanoidRootPart")
			if Settings.AirStrafe and humanoid:GetState() == Enum.HumanoidStateType.FallingDown or Enum.HumanoidStateType.Freefall then
				local moveDirection = humanoid.MoveDirection
				if moveDirection.Magnitude > 0 then
					local rightVector = hrp.CFrame.RightVector
					hrp.Velocity = hrp.Velocity + (rightVector * strafeDirection * 50 * deltaTime)
					
					strafeDirection = -strafeDirection
				end
			end

			if Settings.AutoAllowence == true then
				if game:GetService("ReplicatedStorage").PlayerbaseData2[game:GetService("Players").LocalPlayer.Name].NextAllowance.Value == 0 then
					if not AutoClaimAllowanceCoolDown then
						AutoClaimAllowanceCoolDown = true

						local ATM = GetATM(10)
						if ATM then
							game:GetService("ReplicatedStorage").Events.CLMZALOW:InvokeServer(ATM)
							wait(0.5)
						end

						AutoClaimAllowanceCoolDown = false 
					end
				end
			end			

			if Settings.FullBright == true then
				game:GetService("Lighting").Brightness = 1
				game:GetService("Lighting").ClockTime = 14
				game:GetService("Lighting").FogEnd = 100000
				game:GetService("Lighting").GlobalShadows = false
				game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
			end

			if Settings.UnlockDoorsNearby == true then
				if Settings.IsDead == false then
					for i, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
						if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v:FindFirstChild("DoorBase").Position).Magnitude <= 5 then
							if v:FindFirstChild("Values"):FindFirstChild("Locked").Value == true then
								v:FindFirstChild("Events"):FindFirstChild("Toggle"):FireServer("Unlock", v.Lock)
							end
						end
					end
				end
			end

			if Settings.LockDoorsNearby == true then
				if Settings.IsDead == false then
					for i, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
						if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v:FindFirstChild("DoorBase").Position).Magnitude <= 5 then
							if v:FindFirstChild("Values"):FindFirstChild("Locked").Value == true then
								v:FindFirstChild("Events"):FindFirstChild("Toggle"):FireServer("Lock", v.Lock)
							end
						end
					end
				end
			end

			if Settings.OpenDoorsNearby == true then
				if Settings.IsDead == false then
					for i, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
						if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v:FindFirstChild("DoorBase").Position).Magnitude <= 5 then
							if v:FindFirstChild("Values"):FindFirstChild("Open").Value == false then
								v:FindFirstChild("Events"):FindFirstChild("Toggle"):FireServer("Open", v.Knob2)
							end
						end
					end
				end
			end

			if Settings.IsDead == false then
				if Player.Character:FindFirstChild("Pepper-spray") then
					if Settings.InfinitePepperSpray == true then
						game.Players.LocalPlayer.Character["Pepper-spray"].Ammo.Value = 99
						game.Players.LocalPlayer.Character["Pepper-spray"].RemoteEvent:FireServer("Update", 99)
					end
				end
			end

			if Settings.IsDead == false then
				if Settings.WalkSpeed.Enabled == true then
					Player.Character:FindFirstChild("Humanoid").WalkSpeed = Settings.WalkSpeed.Amount
				end

				if Settings.JumpPower.Enabled == true then
					Player.Character:FindFirstChild("Humanoid").JumpPower = Settings.JumpPower.Amount
				end
			end

			for i, v in pairs(game:GetService("ReplicatedStorage").Storage.HitStuff.Main:GetDescendants()) do
				if v:IsA("Sound") then
					v.Volume = Settings.VolumeHitsound
				end
			end


			if Player.PlayerGui:FindFirstChild("MouseGUI") then
				Player.PlayerGui:FindFirstChild("MouseGUI").HitmarkerSound.Volume = Settings.VolumeHitsound
				Player.PlayerGui:FindFirstChild("MouseGUI").HeadshotSound.Volume = Settings.VolumeHitsound
			end
		end)

		-- #region // Tabs

		-- #region // General Tab

		-- #region // Main Sector
		-- MainS:AddSeperator("The Good Boys")

		MainS:AddToggle("Infinite Stamina", Settings.InfiniteStamina, function(V)
			Settings.InfiniteStamina = V
		end)

		MainS:AddToggle("No Jump Cooldown", Settings.NoJumpCooldown, function(V)
			Settings.NoJumpCooldown = V
		end)

		MiscS:AddToggle("Downed message", Settings.DownedChat, function(V)
			Settings.DownedChat = V
		end)

		MainS:AddToggle("Chat Logs", Settings.ShowChatLogs, function(V)
			Settings.ShowChatLogs = V

			if V == true then
				TextChatService.ChatWindowConfiguration.Enabled = true
			elseif V == false then
				TextChatService.ChatWindowConfiguration.Enabled = false
			end
		end)

		MainS:AddSeperator("Client Side")

		MainS:AddToggle("Full Brightness", Settings.FullBright, function(V)
			Settings.FullBright = V
		end)

		MainS:AddToggle("No Fail Lockpick", Settings.NoFailLockpick, function(V)
			Settings.NoFailLockpick = V
		end)

		MainS:AddToggle("Unlock Nearby Doors", Settings.UnlockDoorsNearby, function(V)
			Settings.UnlockDoorsNearby = V
		end)

		MainS:AddToggle("Lock Nearby Doors", Settings.LockDoorsNearby, function(V)
			Settings.LockDoorsNearby = V
		end)

		MainS:AddToggle("Open Nearby Doors", Settings.OpenDoorsNearby, function(V)
			Settings.OpenDoorsNearby = V
		end)

		MainS:AddToggle("NoClip Doors", Settings.NoClip, function(V)
			Settings.NoClip = V
		end)

		MainS:AddToggle("Auto allowence", Settings.AutoAllowence, function(V)
			Settings.AutoAllowence = V
		end)

		MainS:AddToggle("No Flash", Settings.NoFlashbang, function(V)
			Settings.NoFlashbang = V
		end)

		MainS:AddToggle("No Smoke", Settings.NoSmoke, function(V)
			Settings.NoSmoke = V
		end)

		MainS:AddSlider("Camera Max Zoom", 10, Settings.Zoom, 3000, 10, function(V)
			Player.CameraMaxZoomDistance = V
		end)

		MainS:AddSeperator("Autos")

		MainS:AddToggle("Auto Scrap", Settings.AutoPickScrap, function(V)
			Settings.AutoPickScrap = V
		end)

		MainS:AddToggle("Auto Tools", Settings.AutoPickTools, function(V)
			Settings.AutoPickTools = V
		end)

		MainS:AddToggle("Auto Cash", Settings.AutoPickCash, function(V)
			Settings.AutoPickCash = V
		end)

		-- if syn then
		MainS:AddSeperator("Gods Tools")

		MainS:AddToggle("Disable Barbwire", Settings.NoBarbwire, function(V)
			Settings.NoBarbwire = V
		end)

		MainS:AddToggle("Disable Fall Damage", Settings.NoFallDamage, function(V)
			Settings.NoFallDamage = V
		end)

		MainS:AddToggle("Disable Ragdoll", Settings.NoRagdoll, function(V)
			Settings.NoRagdoll = V
		end)
		-- end
		-- #endregion

		-- #region // Player Sector
		local FOVToggle = PlayerS:AddToggle("Toggle Fov", Settings.CamFovToggled, function(V)
			Settings.CamFovToggled = V
		end, "FOVToggle")

		FOVToggle:AddKeybind("None", "FOVToggle")

		PlayerS:AddSlider("Field Of View", 70, Settings.CamFov, 120, 10, function(V)
			Settings.CamFov = V
		end)

		local Airstrafe = PlayerS:AddToggle("Airstrafe", Settings.AirStrafe, function(V)
			Settings.AirStrafe = V
		end, "Airstrafe")

		-- PlayerS:AddSeperator("Character Mods")

		local WalkSpeedToggle = PlayerS:AddToggle("WalkSpeed Toggeled", Settings.WalkSpeed.Enabled, function(V)
			Settings.WalkSpeed.Enabled = V
		end, "WalkSpeedToggle")

		WalkSpeedToggle:AddKeybind("None", "WalkSpeedToggle")

		local JumpPowerToggle = PlayerS:AddToggle("JumpPower Toggeled", Settings.JumpPower.Enabled, function(V)
			Settings.JumpPower.Enabled = V
		end, "JumpPowerToggle")

		JumpPowerToggle:AddKeybind("None", "JumpPowerToggle")

		PlayerS:AddSlider("WalkSpeed", 16, Settings.WalkSpeed.Amount, 100, 10, function(V)
			Settings.WalkSpeed.Amount = V
		end)

		PlayerS:AddSlider("JumpPower", 30, Settings.JumpPower.Amount, 150, 10, function(V)
			Settings.JumpPower.Amount = V
		end)

		CustomS:AddSeperator("Customization")

		CustomS:AddDropdown("Hit Sounds", {"Yamete", "Suka", "Boink", "TF2", "Rust", "CSGO", "Hitmarker"}, "Yamete", false, function(V)
			local SelectedId = nil

			if V == "Boink" then
				SelectedId = 5451260445
			elseif V == "TF2" then
				SelectedId = 5650646664
			elseif V == "Rust" then
				SelectedId = 5043539486
			elseif V == "CSGO" then
				SelectedId = 8679627751
			elseif V == "Hitmarker" then
				SelectedId = 160432334
			elseif V == "Yamete" then
				SelectedId = 7418243221
			elseif V == "Suka" then
				SelectedId = 5559988698
			end

			Settings.CustomHitSound = SelectedId

			for i, v in pairs(game:GetService("ReplicatedStorage").Storage.HitStuff.Main:GetDescendants()) do
				if v:IsA("Sound") then
					v.SoundId = "rbxassetid://"..SelectedId
				end
			end


			if Player.PlayerGui:FindFirstChild("MouseGUI") then
				Player.PlayerGui:FindFirstChild("MouseGUI").HitmarkerSound.SoundId = "rbxassetid://"..SelectedId
				Player.PlayerGui:FindFirstChild("MouseGUI").HeadshotSound.SoundId = "rbxassetid://"..SelectedId
			end
		end)

		CustomS:AddSlider("Hitsound Volume", 0, Settings.VolumeHitsound, 10, 10, function(V)
			Settings.VolumeHitsound = V
		end)

		CustomS:AddButton("Remove Textures", function()
			for _,v in pairs(workspace:GetDescendants()) do
				if v.ClassName == "Part" or v.ClassName == "SpawnLocation" or v.ClassName == "WedgePart" or v.ClassName == "Terrain" or v.ClassName == "MeshPart" then
					v.Material = "Plastic"
				end
			end

			for i, v in pairs(workspace:GetDescendants()) do
				if v.ClassName == "Decal" or v.ClassName == "Texture" then
					v:Destroy()
				end
			end
		end)
		-- #endregion

		-- #region // Gun Mods Sector
		GunModsS:AddToggle("No Recoil", Settings.GunMods.NoRecoil, function(V)
			Settings.GunMods.NoRecoil = V
		end)

		local SpreadToggle = GunModsS:AddToggle("Custom Spread", Settings.GunMods.Spread, function(V)
			Settings.GunMods.Spread = V
		end, "SpreadToggle")

		SpreadToggle:AddSlider(1, Settings.GunMods.SpreadAmount, 50, 10, function(V)
			Settings.GunMods.SpreadAmount = V
		end)

		GunModsS:AddToggle("Instant Equip", Settings.GunMods.InstantEquip, function(V)
			Settings.GunMods.InstantEquip = V
		end)

		GunModsS:AddToggle("Auto Mode", Settings.GunMods.AutoMode, function(V)
			Settings.GunMods.AutoMode = V
		end)
		-- #endregion

		-- #region // Pepper Sector
		CustomT:AddToggle("Infinite Pepper Spray", Settings.InfinitePepperSpray, function(V)
			Settings.InfinitePepperSpray = V
		end)

		CustomT:AddToggle("Pepper Spray Aura", Settings.PepperSprayAura, function(V)
			Settings.PepperSprayAura = V
		end)
		-- #endregion

		-- #region // Silent Aim
		-- SilentAimS:AddSeperator("- Silent Aim Settings -")

		local SilentToggle = SilentAimS:AddToggle("Silent Aim", SilentSettings.Main.Enabled, function(V)
			SilentSettings.Main.Enabled = V
		end, "SilentToggle")

		SilentToggle:AddKeybind("None", "SilentToggle")

		-- SilentAimS:AddToggle("Visible Check", false, function(V)
		--     SilentSettings.Main.VisibleCheck = V
		-- end)

		SilentAimS:AddDropdown("Hit Part", {"Head", "Torso", "Random"}, "Head", false, function(V)
			SilentSettings.Main.TargetPart = V
		end)

		-- SilentAimS:AddSeperator("- Fov Settings -")

		local SilentAimToggle = SilentAimS:AddToggle("Silent Aim Fov", SilentSettings.FOVSettings.Visible, function(V)
			SilentSettings.FOVSettings.Visible = V
			SilentAIMFov.Visible = V
		end, "SilentAimVisible")

		SilentAimToggle:AddKeybind("None", "SilentAimVisible")

		SilentAimS:AddSlider("Radius", 5, SilentSettings.FOVSettings.Radius, 1080, 10, function(V)
			SilentSettings.FOVSettings.Radius = V
			SilentAIMFov.Radius = V
		end)

		MainS:AddButton("Melee God Mode", function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/NougatBitz/Femware-Leak/main/meleegod.lua", true))()
		end)

		MainS:AddButton("WallBang", function()
			game:service[[Workspace]]:FindFirstChild('Map'):FindFirstChild('Parts'):FindFirstChild('M_Parts').Parent = game:service[[Workspace]]:FindFirstChild('Characters')
		end)
		-- #endregion

		-- #endregion

		-- #region // Visuals Tab

		-- #region // Player Visuals
		local PlayerESPsToggle = PlayerEspS:AddToggle("Toggle ESP's", ESPSettings.PlayerESP.Enabled, function(V)
			ESPSettings.PlayerESP.Enabled = V

			ESPFramework.Color = ESPSettings.ESPColor
			ESPFramework.ToolColor = ESPSettings.ToolColor
			ESPFramework.Tracers = ESPSettings.PlayerESP.TracersOn
			ESPFramework.Names = ESPSettings.PlayerESP.NamesOn
			ESPFramework.Health = ESPSettings.PlayerESP.HealthOn
			ESPFramework.Distance = ESPSettings.PlayerESP.DistanceOn
			ESPFramework.Tool = ESPSettings.PlayerESP.ToolOn
			ESPFramework.Boxes = ESPSettings.PlayerESP.BoxesOn
			ESPFramework.FaceCamera = ESPSettings.PlayerESP.FaceCamOn
			ESPFramework:Toggle(ESPSettings.PlayerESP.Enabled)
		end, "PlayerESPsToggle")

		PlayerESPsToggle:AddKeybind("None", "PlayerESPsToggle")

		PlayerEspS:AddToggle("Boxes", ESPSettings.PlayerESP.BoxesOn, function(V)
			ESPSettings.PlayerESP.BoxesOn = V
			ESPFramework.Boxes = ESPSettings.PlayerESP.BoxesOn
		end)

		PlayerEspS:AddToggle("Tracers", ESPSettings.PlayerESP.TracersOn, function(V)
			ESPSettings.PlayerESP.TracersOn = V
			ESPFramework.Tracers = ESPSettings.PlayerESP.TracersOn
		end)

		PlayerEspS:AddToggle("Name", ESPSettings.PlayerESP.NamesOn, function(V)
			ESPSettings.PlayerESP.NamesOn = V
			ESPFramework.Names = ESPSettings.PlayerESP.NamesOn
		end)

		PlayerEspS:AddToggle("Health", ESPSettings.PlayerESP.HealthOn, function(V)
			ESPSettings.PlayerESP.HealthOn = V
			ESPFramework.Health = ESPSettings.PlayerESP.HealthOn
		end)

		PlayerEspS:AddToggle("Distance", ESPSettings.PlayerESP.DistanceOn, function(V)
			ESPSettings.PlayerESP.DistanceOn = V
			ESPFramework.Distance = ESPSettings.PlayerESP.DistanceOn
		end)

		PlayerEspS:AddToggle("Tool", ESPSettings.PlayerESP.ToolOn, function(V)
			ESPSettings.PlayerESP.ToolOn = V
			ESPFramework.Tool = ESPSettings.PlayerESP.ToolOn
		end)

		PlayerEspS:AddToggle("Face Cam", ESPSettings.PlayerESP.FaceCamOn, function(V)
			ESPSettings.PlayerESP.FaceCamOn = V
			ESPFramework.FaceCamera = ESPSettings.PlayerESP.FaceCamOn
		end)

		-- PlayerEspS:AddSeperator("Dealer")

		PlayerEspS:AddToggle("Drug Dealer", false, function(V)
			ESPFramework.DealerESP = V
		end)

		PlayerEspS:AddToggle("Armory Dealer", false, function(V)
			ESPFramework.ArmoryDealerESP = V
		end)

		PlayerEspS:AddToggle("ATM ESP", false, function(V)
			ESPFramework.AtmESP = V
		end)

		PlayerEspS:AddSlider("ESP Distance", 0, ESPSettings.PlayerESP.Distance, 2000, 10, function(V)
			ESPFramework.DistanceS = V
			ESPSettings.PlayerESP.Distance = V
		end)
		-- #endregion

		-- #region // Scrap Visuals
		local ScrapESPToggle = ScrapEspS:AddToggle("Scrap ESP", ESPSettings.ScrapESP.Enabled, function(V)
			ESPSettings.ScrapESP.Enabled = V

			if V == true then
				for i, v in pairs(game:GetService("Workspace").Filter.SpawnedPiles:GetChildren()) do
					coroutine.wrap(ScrapESP)(v)
				end
			end
		end, "ScrapESPToggle")

		ScrapESPToggle:AddKeybind("None", "ScrapESPToggle")

		-- ScrapEspS:AddSeperator("Rarity")

		ScrapEspS:AddToggle("Legendary Only", ESPSettings.ScrapESP.LegendaryOnly, function(V)
			ESPSettings.ScrapESP.LegendaryOnly = V
		end)

		ScrapEspS:AddToggle("Rare Only", ESPSettings.ScrapESP.RareOnly, function(V)
			ESPSettings.ScrapESP.RareOnly = V
		end)

		ScrapEspS:AddToggle("Good Only", ESPSettings.ScrapESP.GoodOnly, function(V)
			ESPSettings.ScrapESP.GoodOnly = V
		end)

		ScrapEspS:AddToggle("Bad Only", ESPSettings.ScrapESP.BadOnly, function(V)
			ESPSettings.ScrapESP.BadOnly = V
		end)

		-- ScrapEspS:AddSeperator("Distance")

		ScrapEspS:AddSlider("Scrap Distance", 0, ESPSettings.ScrapESP.Distance, 2000, 10, function(V)
			ESPSettings.ScrapESP.Distance = V
		end)
		-- #endregion

		-- #region // Safe Visuals
		local SafeESPToggle = SafeEspS:AddToggle("Safe ESP", ESPSettings.SafeESP.Enabled, function(V)
			ESPSettings.SafeESP.Enabled = V

			if V == true then
				for i, v in pairs(game:GetService("Workspace").Map.BredMakurz:GetChildren()) do
					if tonumber(v:FindFirstChild("Type").Value) == 2 then
						coroutine.wrap(SafeESP)(v, 2)
					elseif tonumber(v:FindFirstChild("Type").Value) == 3 then
						coroutine.wrap(SafeESP)(v, 3)
					end
				end
			end
		end, "SafeESPToggle")

		SafeESPToggle:AddKeybind("None", "SafeESPToggle")

		-- SafeEspS:AddSeperator("Rarity")

		SafeEspS:AddToggle("Big Only", ESPSettings.SafeESP.BigOnly, function(V)
			ESPSettings.SafeESP.BigOnly = V
		end)

		SafeEspS:AddToggle("Small Only", ESPSettings.SafeESP.SmallOnly, function(V)
			ESPSettings.SafeESP.SmallOnly = V
		end)

		-- SafeEspS:AddSeperator("Distance")

		SafeEspS:AddSlider("Safe Distance", 0, ESPSettings.SafeESP.Distance, 2000, 10, function(V)
			ESPSettings.SafeESP.Distance = V
		end)
		-- #endregion

		-- #region // Register Visuals
		local RegisterESPToggle = RegisterEspS:AddToggle("Register ESP", ESPSettings.RegisterESP.Enabled, function(V)
			ESPSettings.RegisterESP.Enabled = V

			if V == true then
				for i, v in pairs(game:GetService("Workspace").Map.BredMakurz:GetChildren()) do
					if tonumber(v:FindFirstChild("Type").Value) == 1 then
						coroutine.wrap(RegisterESP)(v)
					end
				end
			end
		end, "RegisterESPToggle")

		RegisterESPToggle:AddKeybind("None", "RegisterESPToggle")

		-- RegisterEspS:AddSeperator("Distance")

		RegisterEspS:AddSlider("Register Distance", 0, ESPSettings.RegisterESP.Distance, 2000, 10, function(V)
			ESPSettings.RegisterESP.Distance = V
		end)
		-- #endregion

		-- #region // Viewmodel Visuals
		ViewmodelS:AddToggle("Enabled", Settings.ViewModel.Enabled, function(V)
			Settings.ViewModel.Enabled = V
		end)

		ViewmodelS:AddColorpicker("Viewmodel Color", Color3.new(1, 1, 1), function(V)
			Settings.ViewModel.Viewmodel.Color = V
		end) 

		ViewmodelS:AddDropdown("Viewmodel Material", {"ForceField", "Plastic", "Wood", "Slate", "Concrete"}, "ForceField", false, function(V)
			local ThingySelected = nil

			if V == "ForceField" then
				ThingySelected = Enum.Material.ForceField
			elseif V == "Plastic" then
				ThingySelected = Enum.Material.Plastic
			elseif V == "Wood" then
				ThingySelected = Enum.Material.Wood
			elseif V == "Slate" then
				ThingySelected = Enum.Material.Slate
			elseif V == "Concrete" then
				ThingySelected = Enum.Material.Concrete
			end

			Settings.ViewModel.Viewmodel.Material = ThingySelected
		end)

		ViewmodelS:AddColorpicker("Guns Color", Color3.new(1, 1, 1), function(V)
			Settings.ViewModel.Guns.Color = V
		end) 

		ViewmodelS:AddDropdown("Guns Material", {"ForceField", "Plastic", "Wood", "Slate", "Concrete"}, "Plastic", false, function(V)
			local ThingySelected = nil

			if V == "ForceField" then
				ThingySelected = Enum.Material.ForceField
			elseif V == "Plastic" then
				ThingySelected = Enum.Material.Plastic
			elseif V == "Wood" then
				ThingySelected = Enum.Material.Wood
			elseif V == "Slate" then
				ThingySelected = Enum.Material.Slate
			elseif V == "Concrete" then
				ThingySelected = Enum.Material.Concrete
			end

			Settings.ViewModel.Guns.Material = ThingySelected
		end)

		ViewmodelS:AddColorpicker("Melees Color", Color3.new(1, 1, 1), function(V)
			Settings.ViewModel.Melees.Color = V
		end) 

		ViewmodelS:AddDropdown("Melees Material", {"ForceField", "Plastic", "Wood", "Slate", "Concrete"}, "ForceField", false, function(V)
			local ThingySelected = nil

			if V == "ForceField" then
				ThingySelected = Enum.Material.ForceField
			elseif V == "Plastic" then
				ThingySelected = Enum.Material.Plastic
			elseif V == "Wood" then
				ThingySelected = Enum.Material.Wood
			elseif V == "Slate" then
				ThingySelected = Enum.Material.Slate
			elseif V == "Concrete" then
				ThingySelected = Enum.Material.Concrete
			end

			Settings.ViewModel.Melees.Material = ThingySelected
		end)

		ViewmodelS:AddToggle("Hide Left Arm", Settings.ViewModel.LeftArmOff, function(V)
			Settings.ViewModel.LeftArmOff = V
		end)
		-- #endregion

		-- #endregion

		-- #region // Credits Tab

		-- #region // Credits Sector
		CreditsS:AddSeperator("Specials")
		CreditsS:AddLabel("sakuya - Founder")
		CreditsS:AddLabel("Outliers Hub - God Scripter")
		CreditsS:AddLabel("byfr0n - FemWare reborn dev")
		-- CreditsS:AddLabel("hook - Fukin furry")

		local ToggleToggleUI = InfoS:AddToggle("UI Shortcut", true, function(V)
			game:GetService("RunService").RenderStepped:Wait()
			game:GetService("CoreGui"):FindFirstChild(Version).Enabled = V
		end)
		ToggleToggleUI:AddKeybind(Enum.KeyCode.LeftAlt)

		InfoS:AddSeperator("Configurations")
		InfoS:AddColorpicker("Accent 1", Framework.theme.accentcolor, function(V)
			Framework.theme.accentcolor = V
		end)
		InfoS:AddColorpicker("Accent 2", Framework.theme.accentcolor2, function(V)
			Framework.theme.accentcolor2 = V
		end)
		InfoS:AddSeperator("Player ESP Customs")
		InfoS:AddColorpicker("Main ESP", ESPFramework.Color, function(V)
			ESPFramework.Color = V
			ESPSettings.ESPColor = V
		end)
		-- InfoS:AddColorpicker("HealthESP", ESPFramework.HealthColor, function(V)
		--     ESPFramework.HealthColor = V
		--     ESPSettings.HealthColor = V
		-- end)
		-- InfoS:AddColorpicker("DistanceESP", ESPFramework.DistanceColor, function(V)
		--     ESPFramework.DistanceColor = V
		--     ESPSettings.DistanceColor = V
		-- end)
		InfoS:AddColorpicker("Tool ESP", ESPFramework.ToolColor, function(V)
			ESPFramework.ToolColor = V
			ESPSettings.ToolColor = V
		end)
		InfoS:AddColorpicker("Silent Aim Color", SilentSettings.SilentAimColor, function(V)
			SilentAIMFov.Color = V
			SilentSettings.SilentAimColor = V
		end)
		-- local UserIToggle = InfoS:AddToggle("UI ShortKey", Settings.UIKey, function(V)
		--     Settings.UIKey = V
		--     print(Settings.UIKey)
		-- end, "UserIToggle")

		-- UserIToggle:AddKeybind("None", "UserIToggle")

		-- InfoS:AddSeperator("Note")
		-- InfoS:AddLabel("Has pre-loaded script.")
		-- InfoS:AddLabel("Not racist unlike uwu ware.")
		-- InfoS:AddLabel("Poor non Synapse X users.")

		-- #endregion

		-- #region // Misc Sector
		MiscS:AddButton("Get Discord Link", function() JoinDiscord() end)
		MiscS:AddToggle("Toggle Watermark", Settings.WatermarkOn, function(V)
			Watermark.Visible = V
			Settings.WatermarkOn = V
		end)
		-- #endregion

		-- #endregion

		-- #region // Teleports Tab
		local function TeleportArea(Cframe)
			shared.teleport         = true

			local TPCFrame          = Cframe
			local User              = game.Players.LocalPlayer.Character.HumanoidRootPart
			local WaitTime          = 5

			while shared.teleport do wait()

				spawn(function()
					wait(WaitTime)
					shared.teleport = false
				end)

				User.CFrame = TPCFrame

				local args = {
					[1] = "__--r",
					[2] = TPCFrame.Position,
					[3] = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,0,0)
				}

				game:GetService("ReplicatedStorage").Events.__DFfDD:FireServer(unpack(args))

			end
		end



		local function TeleportAreaNew(Cframe)

			local TPCFrame = Cframe
			local User = game.Players.LocalPlayer.Character.HumanoidRootPart

			User.CFrame = TPCFrame
		end

		-- TeleportNew1:AddSeperator("Vibe In-N-Out")
		local db = false
		local db1 = false
		local db2 = false
		local db3 = false

		local function PartThin(p)
			p.Anchored = true
			p.Size = Vector3.new(2, 10, 2)
			p.Material = Enum.Material.ForceField
			p.Color = Color3.fromRGB(255, 255, 255)
			p.CanCollide = false
			p.Transparency = 1
		end

		local part = Instance.new("Part", workspace)
		PartThin(part)
		part.Position = Vector3.new(-4766.666, -32.768, -818.809)

		local part1 = Instance.new("Part", workspace)
		PartThin(part1)
		part1.Position = Vector3.new(-4770.976, -198.929, -842.684)

		local tow = Instance.new("Part", workspace)
		PartThin(tow)
		tow.Position = Vector3.new(-4525.734, 9.314, -778.03)

		local tow1 = Instance.new("Part", workspace)
		PartThin(tow1)
		tow1.Position = Vector3.new(-4525.795, 85.759, -778.03)

		part.Touched:Connect(function()
			if Player and Settings.ElevatorTP then
				if not db and not db1 then
					db = true
					TeleportAreaNew(CFrame.new(-4770.976, -198.929, -842.684))
					wait(1)
					db = false
				end
			end
		end)

		part1.Touched:Connect(function()
			if Player and Settings.ElevatorTP then
				if not db1 and not db then
					db1 = true
					TeleportAreaNew(CFrame.new(-4766.666, -32.768, -818.809))
					wait(1)
					db1 = false
				end
			end
		end)

		tow.Touched:Connect(function()
			if Player and Settings.TowerTP then
				if not d2 and not db3 then
					db2 = true
					TeleportAreaNew(CFrame.new(-4525.795, 85.759, -778.03))
					wait(1)
					db2 = false
				end
			end
		end)

		tow1.Touched:Connect(function()
			if Player and Settings.TowerTP then
				if not db3 and not db2 then
					db3 = true
					TeleportAreaNew(CFrame.new(-4525.734, 9.314, -778.03))
					wait(1)
					db3 = false
				end
			end
		end)

		TeleportNew1:AddToggle("Elevator", Settings.ElevatorTP, function(V)
			Settings.ElevatorTP = V

			if Settings.ElevatorTP == true then
				part.Transparency = 0
				part1.Transparency = 0
			else
				part.Transparency = 1
				part1.Transparency = 1
			end
		end)

		TeleportNew1:AddToggle("Tower", Settings.TowerTP, function(V)
			Settings.TowerTP = V

			if Settings.TowerTP == true then
				tow.Transparency = 0
				tow1.Transparency = 0
			else
				tow.Transparency = 1
				tow1.Transparency = 1
			end
		end)

		TeleportNew1:AddSeperator("Quick Elevator")

		TeleportNew1:AddButton("Elevator Up", function()
			TeleportAreaNew(CFrame.new(-4768.198, -34.303, -817.605))
		end)

		TeleportNew1:AddButton("Elevator Down", function()
			TeleportAreaNew(CFrame.new(-4776.88, -201.662, -823.827))
		end)

		TeleportNew1:AddSeperator("Quick Tower")

		TeleportNew1:AddButton("Tower Up", function()
			TeleportAreaNew(CFrame.new(-4519.51, 85.714, -773.943))
		end)

		-- TeleportAreas1:AddSeperator("Risk of Dying, Anti Exploit")

		TeleportAreas1:AddButton("Vibin Hideout", function()
			TeleportArea(CFrame.new(-4466.548828125, 39.32609939575195, -392.067138671875))
		end)

		TeleportAreas1:AddButton("Cafe", function()
			TeleportArea(CFrame.new(-4646.08251953125, 6.046332836151123, -256.7106018066406))
		end)

		TeleportAreas1:AddButton("Vibin", function()
			TeleportArea(CFrame.new(-4401.146484375, 6.264440059661865, -401.30084228515625))
		end)

		TeleportAreas1:AddButton("Motel", function()
			TeleportArea(CFrame.new(-4694.91650390625, 16.973020553588867, -962.79046630859))
		end)

		TeleportAreas1:AddButton("Tower", function()
			TeleportArea(CFrame.new(-4508.31005859375, 102.73432159423828, -847.6023559570312))
		end)

		TeleportAreas1:AddButton("Factory", function()
			TeleportArea(CFrame.new(-4394.68505859375, 21.600116729736328, -558.8350830078125))
		end)

		TeleportAreas1:AddButton("Armory 1", function()
			TeleportArea(CFrame.new(-4770.51416015625, 3.995715379714966, -409.6304016113281))
		end)

		TeleportAreas1:AddButton("Armory 2", function()
			TeleportArea(CFrame.new(-4200.70166015625, 3.997739553451538, -185.94895935058594))
		end)

		TeleportAreas1:AddButton("Gas Station", function()
			TeleportArea(CFrame.new(-4431.10302734375, 4.0262131690979, 202.88829040527344))
		end)

		TeleportAreas1:AddButton("Pizza Store", function()
			TeleportArea(CFrame.new(-4404.12451171875, 5.199555397033691, -181.91232299804688))
		end)

		TeleportAreas1:AddButton("Thrift Store", function()
			TeleportArea(CFrame.new(-4621.07861328125, 4.099781513214111, -151.47450256347656))
		end)

		TeleportAreas1:AddButton("Subway", function()
			TeleportArea(CFrame.new(-4776.4755859375, -34.77134323120117, -784.1185913085938))
		end)

		TeleportAreas1:AddButton("Vibe Check", function()
			TeleportArea(CFrame.new(-4776.9521484375, -201.26490783691406, -961.081298828125))
		end)





		TeleportAreas2:AddButton("Vibin Hideout", function()
			TeleportArea(CFrame.new(-4466.81689453125, 23.555461883544922, -437.17169189453125))
		end)

		TeleportAreas2:AddButton("Cafe", function()
			TeleportArea(CFrame.new(-4600.1337890625, 3.899446487426758, -278.59722900390625))
		end)

		TeleportAreas2:AddButton("Vibin", function()
			TeleportArea(CFrame.new(-4400.68603515625, 3.295433282852173, -343.2763366699219))
		end)

		TeleportAreas2:AddButton("Motel", function()
			TeleportArea(CFrame.new(-4641.009765625, 3.690157413482666, -905.4984741210938))
		end)

		TeleportAreas2:AddButton("Tower", function()
			TeleportArea(CFrame.new(-4493.49853515625, 3.2909929752349854, -718.6547241210938))
		end)

		TeleportAreas2:AddButton("Factory", function()
			TeleportArea(CFrame.new(-4432.39208984375, 21.59963035583496, -514.9470825195312))
		end)

		TeleportAreas2:AddButton("Armory 1", function()
			TeleportArea(CFrame.new(-4769.7275390625, 3.8944435119628906, -360.00042724609375))
		end)

		TeleportAreas2:AddButton("Armory 2", function()
			TeleportArea(CFrame.new(-4143.83154296875, 3.899510383605957, -183.46885681152344))
		end)

		TeleportAreas2:AddButton("Gas Station", function()
			TeleportArea(CFrame.new(-4429.2177734375, 4.096165657043457, 163.4987335205078))
		end)

		TeleportAreas2:AddButton("Pizza Store", function()
			TeleportArea(CFrame.new(-4361.2314453125, 3.3003010749816895, -139.590087890625))
		end)

		TeleportAreas2:AddButton("Thrift Store", function()
			TeleportArea(CFrame.new(-4623.46044921875, 26.093965530395508, -128.2504882812))
		end)

		TeleportAreas2:AddButton("Subway", function()
			TeleportArea(CFrame.new(-4600.34619140625, 3.899278163909912, -694.621826171875))
		end)





		TeleportAreas3:AddButton("Dealer 1", function()
			TeleportArea(CFrame.new(-4268.42626953125, 3.8942785263061523, 95.84049987792969))
		end)

		TeleportAreas3:AddButton("Dealer 2", function()
			TeleportArea(CFrame.new(-3890.505859375, 3.898646593093872, -165.6616973876953))
		end)

		TeleportAreas3:AddButton("Dealer 3", function()
			TeleportArea(CFrame.new(-4204.54150390625, 4.084814548492432, -548.5355834960938))
		end)

		TeleportAreas3:AddButton("Dealer 4", function()
			TeleportArea(CFrame.new(-4309.11767578125, 3.8976902961730957, -402.10003662109375))
		end)

		TeleportAreas3:AddButton("Dealer 5", function()
			TeleportArea(CFrame.new(-4457.71142578125, 3.8988072872161865, -537.0403442382812))
		end)





		TeleportAreas4:AddButton("ATM 1", function()
			TeleportArea(CFrame.new( -4458.44140625, 3.8995916843414307, -447.21044921875))
		end)

		TeleportAreas4:AddButton("ATM 2", function()
			TeleportArea(CFrame.new( -4679.98779296875, 3.898556709289551, -240.61509704589844))
		end)

		TeleportAreas4:AddButton("ATM 3", function()
			TeleportArea(CFrame.new( -4381.24462890625, 3.99601149559021, -63.50413131713867))
		end)

		TeleportAreas4:AddButton("ATM 4", function()
			TeleportArea(CFrame.new( -4297.296875, 3.8963193893432617, -694.3870239257812))
		end)

		TeleportAreas4:AddButton("ATM 5", function()
			TeleportArea(CFrame.new( -4253.6357421875, 3.9000091552734375, -13.223593711853027))
		end)

		TeleportAreas4:AddButton("ATM 6", function()
			TeleportArea(CFrame.new( -4147.97607421875, 3.894084930419922, -169.73553466796875))
		end)

		TeleportAreas4:AddButton("ATM 7", function()
			TeleportArea(CFrame.new( -4156.0517578125, 3.895453691482544, -210.1305694580078))
		end)

		TeleportAreas4:AddButton("ATM 8", function()
			TeleportArea(CFrame.new( -4068.612548828125, 3.8994336128234863, -289.29461669921875))
		end)

		TeleportAreas4:AddButton("ATM 9", function()
			TeleportArea(CFrame.new( -4395.89794921875, 4.095702171325684, 195.97291564941406))
		end)

		TeleportAreas4:AddButton("ATM 10", function()
			TeleportArea(CFrame.new(-4633.900390625, 3.2963714599609375, -814.0245971679688))
		end)

		TeleportAreas4:AddButton("ATM 11", function()
			TeleportArea(CFrame.new(-4622.1435546875, 3.6649200916290283, -984.0272827148438))
		end)
		-- #endregion

		-- #endregion

		local N = game:GetService("VirtualInputManager")
		N:SendKeyEvent(true, "One", false, game)
		wait(1)
		N:SendKeyEvent(true, "One", false, game)

	end)

	if not Success and Error then
		pcall(function()
			local MSGBox = messagebox("this shit errord mane", "The pasting has failed...", 0)
		end)
	end
end
