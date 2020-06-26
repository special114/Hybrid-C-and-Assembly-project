#include <iostream>
#include <GL/glut.h>
#include "f.h"
using namespace std;

#define W 900
#define H 500
#define BPP 4

unsigned char* pixel_buff = nullptr;
unsigned int* pos = nullptr;

void paintWhite(unsigned char* buf) {
	for (int i = 0; i < W * H * BPP; ++i)
		buf[i] = (char)0xff;
}

void redraw() {
    paintWhite(pixel_buff);
	f(pixel_buff, W, H, pos[0], pos[1], pos[2], pos[3], pos[4], pos[5], pos[6],
        pos[7], pos[8], pos[9]);
    glDrawPixels(W, H, GL_RGBA, GL_UNSIGNED_BYTE, pixel_buff);
    glutSwapBuffers();
}

void displayCallback() {
    redraw();
}
void mouseCallBack(int button, int state, int x, int y){
    static int mouse_clicks = 0;
    if (button == GLUT_LEFT_BUTTON && state == GLUT_DOWN) {
        pos[2 * mouse_clicks] = x;
        pos[2 * mouse_clicks + 1] = (H - y - 1);
        ++mouse_clicks;
        if (mouse_clicks == 5) {
            mouse_clicks = 0;
            redraw();
        }
    }
}

int main(int argc, char** argv) {
    pixel_buff = new unsigned char[W * H * BPP];
    pos = new unsigned int[10];

    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE);
    glutInitWindowSize(W, H);
    glutInitWindowPosition(100, 100);
    glutCreateWindow("Bezier");
    glutDisplayFunc(displayCallback);
	glutMouseFunc(mouseCallBack);
    glutMainLoop();
    delete [] pixel_buff;
    delete [] pos;
    return 0;
}
