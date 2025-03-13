setDefaultTab("Tools")

addSeparator("Upgrader")
macro(500, "Upgrader", function()
    if(storage.item_1_id == nil or storage.item_1_id == 0) then
        return
    end
    for _,item in ipairs(storage.upgraded_items) do
        if(item.id ~= 0) then
            local cur_item = g_game.findPlayerItem(item.id, -1)
            if(cur_item ~= nil) then
                useWith(storage.item_1_id, cur_item)
            end
        end
    end
end)
local ui = UI.createWidget("UpgraderPanel")
local item_1 = ui:recursiveGetChildById("item_1")
local items_list = ui:recursiveGetChildById("items")

local MAX_ITEMS = 20
if(storage.upgraded_items == nil) then
    storage.upgraded_items = {}
end
while(#storage.upgraded_items < MAX_ITEMS) do
    table.insert(storage.upgraded_items, {id = 0, count = 1})
end
function updateAndRedraw()
    new_items = {}
    for i, child in ipairs(items_list:getChildren()) do
      table.insert(new_items, {id = child:getItemId(), count = child:getItemCount()})
    end
    if(#new_items ~= #storage.upgraded_items) then
        storage.upgraded_items = new_items
        drawItems()
    else
        for i=1,#new_items do
            if(new_items[i].id ~= storage.upgraded_items[i].id or new_items[i].count ~= storage.upgraded_items[i].count) then
                storage.upgraded_items = new_items
                drawItems()
            end
        end
    end        
end
function drawItems()
    items_list:destroyChildren()
    for i=1,MAX_ITEMS do
        local widget = g_ui.createWidget("BotItem", items_list)
        widget:setItem(Item.create(storage.upgraded_items[i].id, storage.upgraded_items[i].count))
    end
    for i, child in ipairs(items_list:getChildren()) do
      child.onItemChange = updateAndRedraw
    end
end

item_1:setItemId(storage.item_1_id)
item_1.onItemChange = function()
    storage.item_1_id = item_1:getItemId() 
end
drawItems()