import std.math;
import std.stdio;
import raylib;

struct Sphere {
    Vector3 p;
    float r;
    Color c;
}

int Cw = 640, Ch = 480;
float Vw = 1, Vh = 1;
float d = 1;
Vector3 O = {};
Color BG = Color(50, 50, 50, 255);

Sphere[] spheres = [
    Sphere(Vector3(0, -1, 3), 1, Color(255, 0, 0, 255)),
    Sphere(Vector3(2, 0, 4), 1, Color(0, 0, 255, 255)),
    Sphere(Vector3(-2, 0, 4), 1, Color(0, 255, 0, 255))
];

Vector3 CanvasToViewport(int x, int y) {
    return Vector3(x*Vw/Cw, y*Vh/Ch, d);
}

Color TraceRay(Vector3 start, Vector3 end, float d, float to) {
    float closest_t = float.infinity;
    Sphere *closest_sphere = null;

    float t_min = -float.infinity;
    float t_max = float.infinity;

    foreach (ref s; spheres) {
        auto t = IntersectRaySphere(start, end, s);
        if (t.x >= t_min && t.x <= t_max && t.x < closest_t) {
            closest_t = t.x;
            closest_sphere = &s;
        }
        if (t.y >= t_min && t.y <= t_max && t.y < closest_t) {
            closest_t = t.y;
            closest_sphere = &s;
        }
    }
    if (closest_sphere == null) {
        return BG;
    }
    return closest_sphere.c;
}

Vector2 IntersectRaySphere(Vector3 start, Vector3 end, Sphere sphere) {
    float r = sphere.r;
    auto p = sphere.p;
    Vector3 CO = Vector3(start.x - p.x, start.y - p.y, start.z - p.z);
    auto a = dot(end, end);
    auto b = 2 * dot(CO, end);
    auto c = dot(CO, CO) - r*r;
    
    auto discr = b*b - 4*a*c;
    if (discr < 0) {
        return Vector2(float.infinity, float.infinity);
    }
    
    auto t1 = (-b + sqrt(discr)) / (2*a);
    auto t2 = (-b - sqrt(discr)) / (2*a);

    return Vector2(t1, t2);
}

void draw() {
    for (int x = -Cw/2; x < Cw/2; x++) {
        for (int y = -Ch/2; y < Ch/2; y++) {
            auto D = CanvasToViewport(x, y);
            auto color = TraceRay(O, D, 1, float.infinity);
            DrawPixel(Cw/2 + x, Ch/2 - y, color);
        }
    }
}

void main() {
    validateRaylibBinding();
    InitWindow(Cw, Ch, "Custom renderer");
    SetTargetFPS(60);
    while (!WindowShouldClose()) {
        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);
        draw();
        EndDrawing();
    }
    CloseWindow();
}