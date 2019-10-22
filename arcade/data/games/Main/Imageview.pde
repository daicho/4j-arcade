public class Imageview{

    private PImage images[];
    private boolean runSwitch;
    private int scene ;

    Imageview(){
        images = new PImage[5];
        images[0] = loadImage("title_resources/0.png");
        images[1] = loadImage("title_resources/1.png");
        images[2] = loadImage("title_resources/2.png");
        images[3] = loadImage("title_resources/3.png");
        images[4] = loadImage("title_resources/4.png");
        runSwitch = false;
        scene = 0;
    }

    public void goFrontPage() {
        scene += 1;
        if (scene >= images.length) scene = 0;
    }

    public void goBackPage() {
        scene -= 1;
        if (scene < 0) scene = 4;
    }

    public void HowToPlay(){
        if (!runSwitch) return;
        switch (scene) {
            case 0: image(images[0], width/2, 424); break;
            case 1: image(images[1], width/2, 424); break;
            case 2: image(images[2], width/2, 424); break;
            case 3: image(images[3], width/2, 424); break;
            case 4: image(images[4], width/2, 424); break;
        }
    }

    public void pushSwitch() {
        runSwitch = !runSwitch;
    }

    public boolean isRunnning() {
        return runSwitch;
    }
}
