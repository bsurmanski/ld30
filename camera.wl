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
        .x = .x + ((.focusx - .x) / 20)
        .y = .y + ((.focusy - .y) / 20)
    }

    void setFocus(float x, float y) {
        .focusx = x - 320
        .focusy = y - 240
    }
}
