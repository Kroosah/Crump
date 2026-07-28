shader_type spatial;
// Emissive TL-buis (taak 006, keuze E). Het flikkerniveau komt per
// instantie van het prop-script (instance uniform): licht en buisgloed
// vallen zo altijd samen — één deterministische bron van waarheid voor
// het patroon, en de shader zelf bevat géén eigen tijd of willekeur.

instance uniform float flicker : hint_range(0.0, 1.0) = 1.0;
uniform vec3 albedo : source_color = vec3(0.85, 0.87, 0.9);
uniform vec3 emission_color : source_color = vec3(0.82, 0.88, 1.0);
uniform float emission_energy = 2.4;

void fragment() {
	// Een dode buis is dof grijs, geen zwart gat: contour blijft (HORROR §4).
	ALBEDO = albedo * mix(0.35, 1.0, flicker);
	EMISSION = emission_color * emission_energy * flicker;
}
