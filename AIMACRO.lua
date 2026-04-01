--// AIMACRO PRO (FULL SYSTEM) by chat gpt

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local saveFile = "erc_macro_presets.json"

-- 📦 STATE
local records = {}
local recording = false
local playing = false
local looping = false
local selectedPreset = nil

-- 📁 LOAD FILE
local presets = {}
if isfile and isfile(saveFile) then
    presets = HttpService:JSONDecode(readfile(saveFile))
else
    writefile(saveFile, HttpService:JSONEncode({}))
end

local function savePresets()
    writefile(saveFile, HttpService:JSONEncode(presets))
end

-- 🎥 RECORD
task.spawn(function()
    while true do
        if recording then
            local pos = getmousepos()
            table.insert(records, {x = pos.X, y = pos.Y})
        end
        task.wait(0.07)
    end
end)

-- ▶️ PLAY
local function play()
    if #records == 0 then return end
    playing = true

    for _,v in ipairs(records) do
        if not playing then break end
        
        mousemoveabs(v.x, v.y)
        task.wait(0.01)
        mouse1click()
        task.wait(0.07)
    end
end

-- 🔁 LOOP
task.spawn(function()
    while true do
        if looping and playing then
            play()
        end
        task.wait()
    end
end)

local function stop()
    playing = false
end

-- 🖥️ GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ERC_MACRO_PRO"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 420)
frame.Position = UDim2.new(0.5, -150, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local UIListLayout = Instance.new("UIListLayout", frame)
UIListLayout.Padding = UDim.new(0,5)

local function createBtn(text, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 🔤 INPUT NAME
local nameBox = Instance.new("TextBox", frame)
nameBox.Size = UDim2.new(1, -10, 0, 35)
nameBox.PlaceholderText = "Enter preset name..."
nameBox.Text = ""
nameBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
nameBox.TextColor3 = Color3.new(1,1,1)

-- 🔽 DROPDOWN
local dropdown = Instance.new("TextButton", frame)
dropdown.Size = UDim2.new(1, -10, 0, 35)
dropdown.Text = "Select Preset"
dropdown.BackgroundColor3 = Color3.fromRGB(60,60,60)
dropdown.TextColor3 = Color3.new(1,1,1)

local listFrame = Instance.new("Frame", frame)
listFrame.Size = UDim2.new(1, -10, 0, 0)
listFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
listFrame.ClipsDescendants = true

local listLayout = Instance.new("UIListLayout", listFrame)

local dropdownOpen = false

local function refreshDropdown()
    listFrame:ClearAllChildren()
    listLayout.Parent = listFrame
    
    for name,_ in pairs(presets) do
        local item = Instance.new("TextButton", listFrame)
        item.Size = UDim2.new(1,0,0,30)
        item.Text = name
        item.BackgroundColor3 = Color3.fromRGB(70,70,70)
        item.TextColor3 = Color3.new(1,1,1)

        item.MouseButton1Click:Connect(function()
            selectedPreset = name
            dropdown.Text = "Selected: "..name
            listFrame.Size = UDim2.new(1,-10,0,0)
            dropdownOpen = false
        end)
    end
end

dropdown.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    if dropdownOpen then
        refreshDropdown()
        listFrame.Size = UDim2.new(1,-10,0,120)
    else
        listFrame.Size = UDim2.new(1,-10,0,0)
    end
end)

-- 🔴 RECORD
createBtn("🔴 Start Record", function()
    records = {}
    recording = true
end)

createBtn("🟥 Stop Record", function()
    recording = false
end)

-- ▶️ PLAY
createBtn("▶️ Play", function()
    if selectedPreset then
        records = presets[selectedPreset]
    end
    play()
end)

-- 🔁 LOOP
createBtn("🔁 Toggle Loop", function()
    looping = not looping
    playing = looping
end)

-- ⏹ STOP
createBtn("⏹ Stop", function()
    stop()
end)

-- 💾 SAVE
createBtn("💾 Save Preset", function()
    local name = nameBox.Text
    if name == "" then return end
    
    presets[name] = records
    savePresets()
    refreshDropdown()
end)

-- 📂 LOAD
createBtn("📂 Load Selected", function()
    if selectedPreset then
        records = presets[selectedPreset]
    end
end)

-- 🗑 DELETE
createBtn("🗑 Delete Selected", function()
    if selectedPreset then
        presets[selectedPreset] = nil
        selectedPreset = nil
        dropdown.Text = "Select Preset"
        savePresets()
        refreshDropdown()
    end
end)
