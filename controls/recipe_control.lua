if not fnei.rc.recipe_page then fnei.rc.recipe_page = 1 end
if not fnei.rc.search_stack then fnei.rc.search_stack = {} end
if not fnei.rc.recipe_list then fnei.rc.recipe_list = {} end

require "libs/utils"
require "controls/gui"

function fnei.rc.back_key(player)
	if fnei.gui.is_recipe_open(player) then
		local stack_size = #fnei.rc.search_stack
		if stack_size == 1 then
			fnei.gui.close_recipe(player)
			fnei.rc.delete_recipe_name()
			fnei.mc.open_gui(player)
		elseif stack_size > 1 then
			fnei.rc.delete_recipe_name()
			fnei.rc.set_new_recipe_list(player)
		else
			player.print("fnei.rc.back_key: stack_size value = "..stack_size)
		end
	else
		fnei.mc.back_key(player)
	end
end

function fnei.rc.main_key(player)
	if fnei.gui.is_recipe_open(player) then
		fnei.gui.exit_from_gui(player)
	else
		fnei.mc.main_key(player)
	end
end

function fnei.rc.element_left_click(player, element_name)
	if fnei.rc.insert_recipe_name(player, element_name, "craft") then
		if fnei.gui.is_main_open(player) then
			fnei.gui.close_main(player)
		end
		fnei.rc.set_new_recipe_list(player)
	end
end

function fnei.rc.element_right_click(player, element_name)
	if fnei.rc.insert_recipe_name(player, element_name, "usage") then
		if fnei.gui.is_main_open(player) then
			fnei.gui.close_main(player)
		end
		fnei.rc.set_new_recipe_list(player)
	end
end

function fnei.rc.open_gui(player)
	local cur_page = fnei.rc.recipe_page
	local recipe = fnei.rc.recipe_list[cur_page]
	fnei.gui.open_recipe_gui(player, recipe, cur_page, fnei.rc.get_recipe_amount())
  end

function fnei.rc.set_new_recipe_list(player)
	local elem_num = #fnei.rc.search_stack
	if elem_num < 1 then
		return
	end
	local element = fnei.rc.search_stack[elem_num]

	if (element.type == "craft" and not fnei.rc.set_recipe_list(get_craft_recipe_list(player, element.name))) or
	   (element.type == "usage" and not fnei.rc.set_recipe_list(get_usage_recipe_list(player, element.name))) then
		return
	end
	fnei.rc.open_gui(player)
end


------------------------Name_List--------------------------
function fnei.rc.insert_recipe_name(player, element_name, element_type)
	if element_exist(element_name) then
		if (element_type == "craft" and #get_craft_recipe_list(player, element_name) > 0) or
		   (element_type == "usage" and #get_usage_recipe_list(player, element_name) > 0) then
			table.insert(fnei.rc.search_stack, {name = element_name, type = element_type})
			return true
		end
	end
	return false
end

function fnei.rc.delete_recipe_name()
	table.remove(fnei.rc.search_stack)
end
-----------------------Recipe_List-------------------------
function fnei.rc.set_recipe_list(list)
	if not list or #list == 0 then
		return false
	end
	fnei.rc.recipe_list = list
	fnei.rc.set_recipe_page(1)
	return true
end

function fnei.rc.get_recipe_amount()
	return #fnei.rc.recipe_list
end
------------------------Page-------------------------
function fnei.rc.recipe_gui_next(player)
  fnei.rc.set_recipe_page(fnei.rc.recipe_page + 1)
  fnei.rc.open_gui(player)
end

function fnei.rc.recipe_gui_prev(player)
  fnei.rc.set_recipe_page(fnei.rc.recipe_page - 1)
  fnei.rc.open_gui(player)
end

function fnei.rc.set_recipe_page(value)
  if value < 1 then 
    fnei.rc.recipe_page = 1
    return
  end
  local max_page =  fnei.rc.get_recipe_amount()
  if value > max_page then
    fnei.rc.recipe_page = max_page
    return
  end
  fnei.rc.recipe_page = value
end