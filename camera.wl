import "map.wl"

class Camera {
    float x
    float y

    float focusx
    float focusy

    this() {
        .x = 0
        .y = 0
        .focusx = 0
        .focusy = 0
    }

    void update(Map map) {
        .x = .x + ((.x - .focusx) / 100)
        .y = .y + ((.y - .focusy) / 100)
    }

    void setFocus(float x, float y) {
        .focusx = x
        .focusy = y
    }
}
