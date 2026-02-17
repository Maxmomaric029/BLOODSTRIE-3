#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#include "Math.hpp"
#include "GameStructs.hpp"
#include <vector>

// ==========================================
// FORWARD DECLARATIONS — necesarias porque
// PassthroughWindow referencia floatingBtn y menuCtrl
// antes de que estén definidos más abajo
// ==========================================
@class MenuController;
@class PassthroughWindow;

static PassthroughWindow *menuWindow = nil;
static MenuController    *menuCtrl   = nil;
static UIButton          *floatingBtn = nil;

// ==========================================
// CONFIGURACIÓN DEL MENU / MENU CONFIGURATION
// ==========================================

bool aimbotEnabled    = false;
bool silentAimEnabled = false;
bool espEnabled       = false;
bool godModeEnabled   = false;

// ==========================================
// PASSTHROUGH WINDOW — debe declararse ANTES
// de usarse en SetupMenu()
// ==========================================

@interface PassthroughWindow : UIWindow
@end

@implementation PassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];

    // 1. Si el toque es exactamente el botón flotante, capturarlo
    if (floatingBtn && hitView == floatingBtn) {
        return hitView;
    }

    // 2. Si el menú está abierto y el toque cae dentro, capturarlo
    if (menuCtrl && menuCtrl.menuView && !menuCtrl.menuView.hidden) {
        CGPoint pointInMenu = [menuCtrl.menuView convertPoint:point fromView:self];
        if ([menuCtrl.menuView pointInside:pointInMenu withEvent:event]) {
            return hitView;
        }
    }

    // 3. Cualquier otro toque se pasa al juego
    return nil;
}
@end

// ==========================================
// MENU CONTROLLER
// ==========================================

@interface MenuController : UIViewController
@property (nonatomic, strong) UIView   *menuView;
@property (nonatomic, strong) UISwitch *aimbotSwitch;
@property (nonatomic, strong) UISwitch *silentAimSwitch;
@property (nonatomic, strong) UISwitch *espSwitch;
@property (nonatomic, strong) UISwitch *godModeSwitch;
@end

@implementation MenuController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    self.menuView.center = self.view.center;
    self.menuView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    self.menuView.layer.cornerRadius = 10;
    self.menuView.layer.borderColor  = [UIColor redColor].CGColor;
    self.menuView.layer.borderWidth  = 2;
    self.menuView.hidden = YES;
    [self.view addSubview:self.menuView];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 30)];
    title.text          = @"Project Bloodstrike iOS Mod";
    title.textColor     = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font          = [UIFont boldSystemFontOfSize:18];
    [self.menuView addSubview:title];

    [self createSwitchWithLabel:@"Aimbot"          yPos:50  selector:@selector(toggleAimbot:)];
    [self createSwitchWithLabel:@"Silent Aim (Kill)" yPos:90  selector:@selector(toggleSilentAim:)];
    [self createSwitchWithLabel:@"ESP"             yPos:130 selector:@selector(toggleESP:)];
    [self createSwitchWithLabel:@"God Mode"        yPos:170 selector:@selector(toggleGodMode:)];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(100, 250, 100, 30);
    [closeBtn setTitle:@"Ocultar" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:closeBtn];
}

- (void)createSwitchWithLabel:(NSString *)label yPos:(CGFloat)y selector:(SEL)selector {
    UILabel *lbl   = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 150, 30)];
    lbl.text       = label;
    lbl.textColor  = [UIColor whiteColor];
    [self.menuView addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(200, y, 50, 30)];
    [sw addTarget:self action:selector forControlEvents:UIControlEventValueChanged];
    [self.menuView addSubview:sw];
}

- (void)toggleAimbot:(UISwitch *)sender    { aimbotEnabled    = sender.isOn; NSLog(@"[ModMenu] Aimbot: %@",     sender.isOn ? @"ON" : @"OFF"); }
- (void)toggleSilentAim:(UISwitch *)sender { silentAimEnabled = sender.isOn; NSLog(@"[ModMenu] Silent Aim: %@", sender.isOn ? @"ON" : @"OFF"); }
- (void)toggleESP:(UISwitch *)sender       { espEnabled       = sender.isOn; NSLog(@"[ModMenu] ESP: %@",        sender.isOn ? @"ON" : @"OFF"); }
- (void)toggleGodMode:(UISwitch *)sender   { godModeEnabled   = sender.isOn; NSLog(@"[ModMenu] God Mode: %@",   sender.isOn ? @"ON" : @"OFF"); }

- (void)hideMenu   { self.menuView.hidden = YES; }
- (void)toggleMenu { self.menuView.hidden = !self.menuView.hidden; }

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    UIView *view       = recognizer.view;
    CGPoint translation = [recognizer translationInView:view.superview];
    view.center = CGPointMake(view.center.x + translation.x,
                              view.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:view.superview];
}

@end

// ==========================================
// LÓGICA DEL HACK / HACK LOGIC
// ==========================================

// Obtiene bounds de pantalla sin usar mainScreen depreciado
CGRect GetScreenBounds() {
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive
            && [scene isKindOfClass:[UIWindowScene class]]) {
            return ((UIWindowScene *)scene).screen.bounds;
        }
    }
    // Fallback silencioso (iOS < 13)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [UIScreen mainScreen].bounds;
#pragma clang diagnostic pop
}

bool WorldToScreen(Vec3 worldPos, Vector2 &screenPos, Matrix4x4 viewProj) {
    float x = worldPos.x * viewProj.m[0][0] + worldPos.y * viewProj.m[1][0] + worldPos.z * viewProj.m[2][0] + viewProj.m[3][0];
    float y = worldPos.x * viewProj.m[0][1] + worldPos.y * viewProj.m[1][1] + worldPos.z * viewProj.m[2][1] + viewProj.m[3][1];
    float w = worldPos.x * viewProj.m[0][3] + worldPos.y * viewProj.m[1][3] + worldPos.z * viewProj.m[2][3] + viewProj.m[3][3];

    if (w < 0.01f) return false;

    float invW = 1.0f / w;
    x *= invW;
    y *= invW;

    CGRect bounds = GetScreenBounds();
    float width  = bounds.size.width;
    float height = bounds.size.height;

    screenPos.x = (width  / 2.0f) + (x * width  / 2.0f);
    screenPos.y = (height / 2.0f) - (y * height / 2.0f);
    return true;
}

void HackLoop() {
    uintptr_t baseAddr = (uintptr_t)_dyld_get_image_header(0);

    // Centro de pantalla calculado una sola vez (se refresca si cambia orientación)
    CGRect bounds = GetScreenBounds();
    Vector2 screenCenter = { (float)(bounds.size.width  / 2.0f),
                              (float)(bounds.size.height / 2.0f) };

    while (true) {
        if (aimbotEnabled || espEnabled || silentAimEnabled) {
            uintptr_t d3d11DevicePtr = *(uintptr_t*)(baseAddr + adrD3D11Device);
            uintptr_t objectsBasePtr = *(uintptr_t*)(baseAddr + adrObjects);
            uintptr_t localPlayerPtr = *(uintptr_t*)(baseAddr + OFF_LocalPlayer);

            if (d3d11DevicePtr && objectsBasePtr) {
                uintptr_t cameraInfoPtr = *(uintptr_t*)(d3d11DevicePtr + D3D11Device_CameraInfo);
                uintptr_t p1            = *(uintptr_t*)(objectsBasePtr  + ptrObject1);

                if (cameraInfoPtr && p1) {
                    // FIX: info ya no queda sin usar — lo usamos en WorldToScreen
                    CameraInfo *info    = (CameraInfo*)cameraInfoPtr;
                    GameVector *objects = (GameVector*)(p1 + ptrObject2);
                    int count = (int)((objects->End - objects->Begin) / sizeof(uintptr_t));

                    uintptr_t bestTarget = 0;
                    float minDistance    = 9999.0f;

                    if (count > 0 && count < 1000) {
                        for (int i = 0; i < count; i++) {
                            uintptr_t curObject = *(uintptr_t*)(objects->Begin + i * sizeof(uintptr_t));
                            if (!curObject) continue;
                            uintptr_t curEntityPtr = *(uintptr_t*)(curObject - 0x10);
                            if (!curEntityPtr) continue;

                            Entity *ent = (Entity*)curEntityPtr;
                            if (ent->IsDead) continue;

                            Vector2 screenPos;
                            if (WorldToScreen(ent->Origin, screenPos, info->ViewProj)) {
                                float dist = sqrtf(powf(screenPos.x - screenCenter.x, 2) +
                                                   powf(screenPos.y - screenCenter.y, 2));
                                if (dist < minDistance) {
                                    minDistance = dist;
                                    bestTarget  = curEntityPtr;
                                }
                            }
                        }
                    }

                    // Silent Aim / Aimkill
                    if (silentAimEnabled && bestTarget && localPlayerPtr) {
                        bool isShooting = *(bool*)(localPlayerPtr + OFF_sAim1);
                        if (isShooting) {
                            uintptr_t weaponData = *(uintptr_t*)(localPlayerPtr + OFF_sAim2);
                            if (weaponData) {
                                Entity *targetEnt = (Entity*)bestTarget;
                                Vec3 targetHead   = targetEnt->Origin;
                                targetHead.y     += 0.1f;

                                Vec3 startPos    = *(Vec3*)(weaponData + OFF_sAim3);
                                Vec3 aimPosition = targetHead - startPos;
                                *(Vec3*)(weaponData + OFF_sAim4) = aimPosition;
                            }
                        }
                    }
                }
            }
        }
        [NSThread sleepForTimeInterval:0.01]; // ~100 Hz
    }
}

// ==========================================
// PUNTO DE ENTRADA / ENTRY POINT
// ==========================================

void SetupMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        UIWindowScene *scene = nil;
        for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
            if ([s isKindOfClass:[UIWindowScene class]]) {
                scene = (UIWindowScene *)s;
                break;
            }
        }

        CGRect bounds = GetScreenBounds();

        if (scene) {
            menuWindow = [[PassthroughWindow alloc] initWithWindowScene:scene];
        } else {
            menuWindow = [[PassthroughWindow alloc] initWithFrame:bounds];
        }

        menuWindow.windowLevel      = UIWindowLevelAlert + 1;
        menuWindow.backgroundColor  = [UIColor clearColor];

        menuCtrl                    = [[MenuController alloc] init];
        menuWindow.rootViewController = menuCtrl;
        [menuWindow makeKeyAndVisible];

        // Botón flotante
        floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame                   = CGRectMake(0, 100, 50, 50);
        floatingBtn.backgroundColor         = [UIColor redColor];
        floatingBtn.layer.cornerRadius       = 25;
        [floatingBtn setTitle:@"M" forState:UIControlStateNormal];
        [floatingBtn addTarget:menuCtrl
                        action:@selector(toggleMenu)
              forControlEvents:UIControlEventTouchUpInside];

        UIPanGestureRecognizer *pan =
            [[UIPanGestureRecognizer alloc] initWithTarget:menuCtrl
                                                    action:@selector(handlePan:)];
        [floatingBtn addGestureRecognizer:pan];
        [menuWindow addSubview:floatingBtn];

        // Hilo del hack
        [NSThread detachNewThreadSelector:@selector(runHack)
                                 toTarget:[MenuController class]
                               withObject:nil];
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

// Constructor estático — se ejecuta al inyectar la dylib
__attribute__((constructor))
static void initialize() {
    NSLog(@"[ModMenu] Injected successfully!");
    SetupMenu();
}
