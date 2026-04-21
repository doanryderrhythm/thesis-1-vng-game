shader_type canvas_item;

uniform float time_multi = 0.1;

void vertex() {
	UV.x += TIME * time_multi;
	UV.y += TIME * time_multi;
}
