extends RefCounted
## Catalog and primitive models for everything the Ishtiha menu can spawn.
## Each entry: id -> [label, category, note about its source or "creator's design"].

const P = preload("res://prims.gd")

const CATEGORIES := ["Fruits", "Drinks", "Food", "Seating", "Garden"]

const ITEMS := {
	"dates": ["Dates", "Fruits", "Fruit named in the Quran (55:68)"],
	"grapes": ["Grapes", "Fruits", "Gardens of grapes (78:32)"],
	"pomegranate": ["Pomegranate", "Fruits", "Fruit named in the Quran (55:68)"],
	"figs": ["Figs", "Fruits", "Sworn by in the Quran (95:1)"],
	"banana": ["Banana (talh)", "Fruits", "Layered talh (56:29)"],
	"water": ["Cup of water", "Drinks", "River of water (47:15)"],
	"milk": ["Cup of milk", "Drinks", "River of milk (47:15)"],
	"honey": ["Cup of honey", "Drinks", "River of purified honey (47:15)"],
	"ginger_drink": ["Zanjabil drink", "Drinks", "Cup mixed with ginger (76:17)"],
	"bird": ["Roasted bird", "Food", "Flesh of fowl (56:21)"],
	"bread_platter": ["Platter of fruit", "Food", "Fruits of their choice (56:20)"],
	"couch": ["Raised couch", "Seating", "Couches raised high (88:13)"],
	"cushions": ["Cushions", "Seating", "Cushions set in rows (88:15)"],
	"carpet": ["Carpet", "Seating", "Rich carpets spread out (88:16)"],
	"tree": ["Shade tree", "Garden", "Shade spread out (56:30)"],
	"flowerbed": ["Flower bed", "Garden", "Creator's design"],
}


static func ids_in(category: String) -> Array:
	var out: Array = []
	for id in ITEMS:
		if ITEMS[id][1] == category:
			out.append(id)
	return out


static func make(id: String) -> Node3D:
	var n := Node3D.new()
	n.name = id
	var gold := P.mat(Color(0.86, 0.69, 0.28), 0.25, 0.85)
	match id:
		"dates":
			_cluster(n, 9, Color(0.35, 0.18, 0.1), 0.1, true)
		"grapes":
			_cluster(n, 24, Color(0.45, 0.15, 0.55), 0.09, true)
		"pomegranate":
			for k in 3:
				P.ball(n, 0.2, Vector3(k * 0.35 - 0.35, 0.2, 0.0), P.mat(Color(0.75, 0.08, 0.14), 0.35))
				P.ball(n, 0.06, Vector3(k * 0.35 - 0.35, 0.4, 0.0), P.mat(Color(0.75, 0.08, 0.14), 0.35))
		"figs":
			for k in 4:
				P.ball(n, 0.15, Vector3(k * 0.3 - 0.45, 0.15, 0.0), P.mat(Color(0.4, 0.2, 0.4), 0.5), Vector3(0.8, 1.1, 0.8))
		"banana":
			for k in 4:
				P.cyl(n, 0.07, 0.06, 0.6, Vector3(k * 0.14 - 0.2, 0.4, 0), P.mat(Color(0.98, 0.85, 0.2), 0.5), Vector3(0, 0, 18 - k * 8))
		"water":
			_cup(n, gold, Color(0.45, 0.72, 0.95, 0.8))
		"milk":
			_cup(n, gold, Color(0.98, 0.98, 0.95, 0.95))
		"honey":
			_cup(n, gold, Color(0.93, 0.6, 0.1, 0.95))
		"ginger_drink":
			_cup(n, gold, Color(0.9, 0.8, 0.5, 0.92))
		"bird":
			P.ball(n, 0.28, Vector3(0, 0.3, 0), P.mat(Color(0.65, 0.35, 0.15), 0.6), Vector3(1.2, 0.9, 1.0))
			P.ball(n, 0.12, Vector3(0.3, 0.4, 0), P.mat(Color(0.65, 0.35, 0.15), 0.6))
			P.cyl(n, 0.4, 0.4, 0.05, Vector3(0, 0.02, 0), gold, Vector3.ZERO, false, 20)
		"bread_platter":
			P.cyl(n, 0.55, 0.5, 0.06, Vector3(0, 0.03, 0), gold, Vector3.ZERO, false, 24)
			var cols := [Color(0.85, 0.1, 0.15), Color(0.55, 0.15, 0.55), Color(0.98, 0.78, 0.15), Color(0.3, 0.7, 0.3)]
			for k in 8:
				var a := k * TAU / 8.0
				P.ball(n, 0.1, Vector3(cos(a) * 0.3, 0.14, sin(a) * 0.3), P.mat(cols[k % 4], 0.4))
		"couch":
			var silk := P.mat(Color(0.96, 0.9, 0.75), 0.4)
			var green := P.mat(Color(0.1, 0.4, 0.22), 0.5)
			P.box(n, Vector3(2.6, 0.7, 1.1), Vector3(0, 0.35, 0), gold, Vector3.ZERO, true)
			P.box(n, Vector3(2.4, 0.25, 0.95), Vector3(0, 0.8, 0), silk)
			P.box(n, Vector3(2.4, 0.8, 0.2), Vector3(0, 1.2, -0.45), green)
		"cushions":
			var cols2 := [Color(0.1, 0.4, 0.22), Color(0.96, 0.9, 0.75), Color(0.86, 0.69, 0.28)]
			for k in 3:
				P.ball(n, 0.35, Vector3(k * 0.7 - 0.7, 0.2, 0), P.mat(cols2[k], 0.5), Vector3(1.2, 0.5, 1.0))
		"carpet":
			P.box(n, Vector3(3.4, 0.05, 2.4), Vector3(0, 0.03, 0), P.mat(Color(0.1, 0.4, 0.22), 0.6))
			P.box(n, Vector3(3.0, 0.06, 2.0), Vector3(0, 0.04, 0), gold)
			P.box(n, Vector3(2.8, 0.07, 1.8), Vector3(0, 0.05, 0), P.mat(Color(0.96, 0.9, 0.75), 0.6))
		"tree":
			P.cyl(n, 0.2, 0.32, 4.0, Vector3(0, 2.0, 0), P.mat(Color(0.4, 0.28, 0.18), 0.9), Vector3.ZERO, true, 10)
			var lm := P.mat(Color(0.2, 0.55, 0.25), 0.85)
			P.ball(n, 2.6, Vector3(0, 4.7, 0), lm, Vector3(1.0, 0.75, 1.0))
		"flowerbed":
			P.cyl(n, 1.5, 1.5, 0.15, Vector3(0, 0.08, 0), P.mat(Color(0.3, 0.55, 0.3), 0.9), Vector3.ZERO, false, 20)
			var cols3 := [Color(0.95, 0.35, 0.5), Color(0.99, 0.99, 0.95), Color(0.99, 0.85, 0.2), Color(0.7, 0.45, 0.9)]
			var rng := RandomNumberGenerator.new()
			rng.seed = 3
			for k in 24:
				var a := rng.randf() * TAU
				var r := sqrt(rng.randf()) * 1.3
				P.ball(n, 0.1, Vector3(cos(a) * r, rng.randf_range(0.25, 0.45), sin(a) * r), P.mat(cols3[k % 4], 0.6))
	return n


static func _cup(n: Node3D, gold: Material, liquid: Color) -> void:
	P.cyl(n, 0.2, 0.12, 0.34, Vector3(0, 0.17, 0), gold, Vector3.ZERO, false, 16)
	P.cyl(n, 0.17, 0.17, 0.02, Vector3(0, 0.32, 0), P.mat(liquid, 0.05, 0.1, 0.25, Color(liquid.r, liquid.g, liquid.b)), Vector3.ZERO, false, 16)
	P.cyl(n, 0.2, 0.25, 0.03, Vector3(0, 0.015, 0), gold, Vector3.ZERO, false, 16)


static func _cluster(n: Node3D, count: int, color: Color, r: float, hang: bool) -> void:
	var m := P.mat(color, 0.4)
	var rng := RandomNumberGenerator.new()
	rng.seed = count
	for k in count:
		var t := float(k) / count
		var spread := (1.0 - t) * 0.3
		P.ball(n, r, Vector3(rng.randf_range(-spread, spread), 0.15 + t * 0.55, rng.randf_range(-spread, spread)), m)
	P.cyl(n, 0.02, 0.03, 0.2, Vector3(0, 0.82, 0), P.mat(Color(0.35, 0.28, 0.15), 0.9))
