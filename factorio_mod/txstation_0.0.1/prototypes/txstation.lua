local txStation_item = table.deepcopy(data.raw.item["substation"])

txStation_item.name = "tx-station"
txStation_item.icons = {
    {
        icon=txStation_item.icon,
		tint={r=1,g=0.1,b=0.1,a=0.3}
	}
}

txStation_item.place_result = "tx-station"

local txStation_entity = table.deepcopy(data.raw["electric-pole"]["substation"])

txStation_entity.name = "tx-station"
txStation_entity.maximum_wire_distance = 64
txStation_entity.max_health = 1000
txStation_entity.supply_area_distance = 0
txStation_entity.auto_connect_up_to_n_wires = 0
txStation_entity.minable = {mining_time = 0.5, results = {{type="item", name="tx-station", amount=1}}}
txStation_entity.pictures.layers[1].tint = {r= 1.0, g = 0.1, b = 0.1, a = 1}
txStation_entity.surface_conditions = {
    {
        property = "gravity",
        min = nil
    }
}

local recipe = table.deepcopy(data.raw.recipe["substation"])

recipe.enabled = true
recipe.name = "tx-station"
recipe.ingredients = {{type="item", name="iron-plate", amount=1}}
recipe.results = {{type="item", name="tx-station", amount=1}}

data:extend{txStation_item, txStation_entity, recipe}


