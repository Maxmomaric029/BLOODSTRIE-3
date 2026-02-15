#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#include "Math.hpp"
#include "GameStructs.hpp"
#include <vector>

// ==========================================
// CONFIGURACIÓN DEL MENU / MENU CONFIGURATION
// ==========================================

// Variables globales para el estado de los trucos
bool aimbotEnabled = false;
bool espEnabled = false;
bool godModeEnabled = false;

@interface MenuController : UIViewController
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UISwitch *aimbotSwitch;
@property (nonatomic, strong) UISwitch *espSwitch;
@property (nonatomic, strong) UISwitch *godModeSwitch;
@end

@implementation MenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Crear ventana del menú (Menu Window)
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    self.menuView.center = self.view.center;
    self.menuView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    self.menuView.layer.cornerRadius = 10;
    self.menuView.layer.borderColor = [UIColor redColor].CGColor;
    self.menuView.layer.borderWidth = 2;
    self.menuView.hidden = YES; // Empieza oculto
    [self.view addSubview:self.menuView];

    // Título (Title)
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 30)];
    title.text = @"Project Bloodstrike iOS Mod";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];
    [self.menuView addSubview:title];

    // Aimbot Switch
    [self createSwitch:@"Aimbot" yPos:50 target:self selector:@selector(toggleAimbot:) ref:self.aimbotSwitch];
    
    // ESP Switch
    [self createSwitch:@"ESP" yPos:100 target:self selector:@selector(toggleESP:) ref:self.espSwitch];
    
    // God Mode Switch
    [self createSwitch:@"God Mode" yPos:150 target:self selector:@selector(toggleGodMode:) ref:self.godModeSwitch];
    
    // Botón Cerrar (Close Button)
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(100, 200, 100, 30);
    [closeBtn setTitle:@"Ocultar" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:closeBtn];
}

- (void)createSwitch:(NSString*)label yPos:(CGFloat)y target:(id)target selector:(SEL)selector ref:(UISwitch*)ref {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 150, 30)];
    lbl.text = label;
    lbl.textColor = [UIColor whiteColor];
    [self.menuView addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(200, y, 50, 30)];
    [sw addTarget:target action:selector forControlEvents:UIControlEventValueChanged];
    [self.menuView addSubview:sw];
}

- (void)toggleAimbot:(UISwitch*)sender {
    aimbotEnabled = sender.isOn;
    NSLog(@"[ModMenu] Aimbot: %@", aimbotEnabled ? @"ON" : @"OFF");
}

- (void)toggleESP:(UISwitch*)sender {
    espEnabled = sender.isOn;
    NSLog(@"[ModMenu] ESP: %@", espEnabled ? @"ON" : @"OFF");
}

- (void)toggleGodMode:(UISwitch*)sender {
    godModeEnabled = sender.isOn;
    NSLog(@"[ModMenu] God Mode: %@", godModeEnabled ? @"ON" : @"OFF");
}

- (void)hideMenu {
    self.menuView.hidden = YES;
}

- (void)toggleMenu {
    self.menuView.hidden = !self.menuView.hidden;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    UIView *view = recognizer.view;
    CGPoint translation = [recognizer translationInView:view.superview];
    view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:view.superview];
}

@end

// ==========================================
// LÓGICA DEL HACK / HACK LOGIC
// ==========================================

bool WorldToScreen(Vec3 worldPos, Vector2 &screenPos, Matrix4x4 viewProj) {
    float x = worldPos.x * viewProj.m[0][0] + worldPos.y * viewProj.m[1][0] + worldPos.z * viewProj.m[2][0] + viewProj.m[3][0];
    float y = worldPos.x * viewProj.m[0][1] + worldPos.y * viewProj.m[1][1] + worldPos.z * viewProj.m[2][1] + viewProj.m[3][1];
    float w = worldPos.x * viewProj.m[0][3] + worldPos.y * viewProj.m[1][3] + worldPos.z * viewProj.m[2][3] + viewProj.m[3][3];

    if (w < 0.01f) return false;

    float invW = 1.0f / w;
    x *= invW;
    y *= invW;

    CGRect screenBounds = [UIScreen mainScreen].bounds;
    // En iOS modernos, preferiblemente usar el bounds de la escena si es posible, 
    // pero para un dylib inyectado esto suele ser suficiente o ajustable.
    float width = screenBounds.size.width;
    float height = screenBounds.size.height;

    screenPos.x = (width / 2.0f) + (x * width / 2.0f);
    screenPos.y = (height / 2.0f) - (y * height / 2.0f);

    return true;
}

void HackLoop() {
    uintptr_t baseAddr = (uintptr_t)_dyld_get_image_header(0);
    
    while (true) {
        if (aimbotEnabled || espEnabled) {
            uintptr_t d3d11DevicePtr = *(uintptr_t*)(baseAddr + adrD3D11Device);
            uintptr_t objectsBasePtr = *(uintptr_t*)(baseAddr + adrObjects);
            
            if (d3d11DevicePtr && objectsBasePtr) {
                uintptr_t cameraInfoPtr = *(uintptr_t*)(d3d11DevicePtr + D3D11Device_CameraInfo);
                uintptr_t p1 = *(uintptr_t*)(objectsBasePtr + ptrObject1);
                
                if (cameraInfoPtr && p1) {
                    CameraInfo *info = (CameraInfo*)cameraInfoPtr;
                    (void)info; // Marcar como usado para evitar warning
                    GameVector *objects = (GameVector*)(p1 + ptrObject2);
                    
                    int count = (objects->End - objects->Begin) / sizeof(uintptr_t);
                    if (count > 0 && count < 1000) { // Safety check
                        for (int i = 0; i < count; i++) {
                            uintptr_t curObject = *(uintptr_t*)(objects->Begin + i * sizeof(uintptr_t));
                            if (curObject) {
                                uintptr_t curEntityPtr = *(uintptr_t*)(curObject - 0x10);
                                if (curEntityPtr) {
                                    // ESP logic
                                }
                            }
                        }
                    }
                }
            }
        }
        [NSThread sleepForTimeInterval:0.01]; // ~100 FPS
    }
}

// ==========================================
// PUNTO DE ENTRADA / ENTRY POINT
// ==========================================

static UIWindow *menuWindow = nil;
static MenuController *menuCtrl = nil;
static UIButton *floatingBtn = nil;

void SetupMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = nil;
        for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
            if ([s isKindOfClass:[UIWindowScene class]]) {
                scene = (UIWindowScene *)s;
                break;
            }
        }

        if (scene) {
            menuWindow = [[UIWindow alloc] initWithWindowScene:scene];
        } else {
            menuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }

        menuWindow.windowLevel = UIWindowLevelAlert + 1;
        menuWindow.backgroundColor = [UIColor clearColor];
        
        menuCtrl = [[MenuController alloc] init];
        menuWindow.rootViewController = menuCtrl;
        [menuWindow makeKeyAndVisible];
        
        // Botón flotante para abrir el menú
        floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame = CGRectMake(0, 100, 50, 50);
        floatingBtn.backgroundColor = [UIColor redColor];
        floatingBtn.layer.cornerRadius = 25;
        [floatingBtn setTitle:@"M" forState:UIControlStateNormal];
        [floatingBtn addTarget:menuCtrl action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        
        // Add gesture recognizer for dragging
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:menuCtrl action:@selector(handlePan:)];
        [floatingBtn addGestureRecognizer:pan];
        
        [menuWindow addSubview:floatingBtn]; // Añadir a nuestra propia ventana de alerta
        
        // Iniciar el hilo del hack
        [NSThread detachNewThreadSelector:@selector(runHack) toTarget:[MenuController class] withObject:nil];
    });
}

@interface MenuController (HackThread)
+ (void)runHack;
@end

@implementation MenuController (HackThread)
+ (void)runHack {
    HackLoop();
}
@end

// Constructor estático para cargar al inyectar
__attribute__((constructor))
static void initialize() {
    NSLog(@"[ModMenu] Injected successfully!");
    SetupMenu();
}


