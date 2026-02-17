#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#include "Math.hpp"
#include "GameStructs.hpp"
#include <vector>

// ==========================================
// VARIABLES GLOBALES
// ==========================================
bool aimbotEnabled    = false;
bool silentAimEnabled = false;
bool espEnabled       = false;
bool godModeEnabled   = false;

static UIWindow  *menuWindow  = nil;
static UIButton  *floatingBtn = nil;

// ==========================================
// HELPERS
// ==========================================
CGRect GetScreenBounds() {
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive
            && [scene isKindOfClass:[UIWindowScene class]]) {
            return ((UIWindowScene *)scene).screen.bounds;
        }
    }
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            return ((UIWindowScene *)scene).screen.bounds;
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [UIScreen mainScreen].bounds;
#pragma clang diagnostic pop
}

static UIWindowScene *GetActiveWindowScene() {
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]])
            return (UIWindowScene *)scene;
    }
    return nil;
}

// ==========================================
// MENU CONTROLLER — definición completa PRIMERO
// PassthroughWindow la necesita completa para acceder a .menuView
// ==========================================
@interface MenuController : UIViewController
@property (nonatomic, strong) UIView   *menuView;
@property (nonatomic, strong) UISwitch *aimbotSwitch;
@property (nonatomic, strong) UISwitch *silentAimSwitch;
@property (nonatomic, strong) UISwitch *espSwitch;
@property (nonatomic, strong) UISwitch *godModeSwitch;
- (void)toggleMenu;
- (void)handlePan:(UIPanGestureRecognizer *)r;
@end

static MenuController *menuCtrl = nil;

@implementation MenuController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    self.menuView.center             = self.view.center;
    self.menuView.backgroundColor    = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    self.menuView.layer.cornerRadius = 10;
    self.menuView.layer.borderColor  = [UIColor redColor].CGColor;
    self.menuView.layer.borderWidth  = 2;
    self.menuView.hidden             = YES;
    [self.view addSubview:self.menuView];

    UILabel *title      = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 30)];
    title.text          = @"Project Bloodstrike iOS Mod";
    title.textColor     = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font          = [UIFont boldSystemFontOfSize:18];
    [self.menuView addSubview:title];

    [self addRow:@"Aimbot"            y:50  sel:@selector(toggleAimbot:)];
    [self addRow:@"Silent Aim (Kill)" y:90  sel:@selector(toggleSilentAim:)];
    [self addRow:@"ESP"               y:130 sel:@selector(toggleESP:)];
    [self addRow:@"God Mode"          y:170 sel:@selector(toggleGodMode:)];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(100, 250, 100, 30);
    [closeBtn setTitle:@"Ocultar" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:closeBtn];
}

- (void)addRow:(NSString *)label y:(CGFloat)y sel:(SEL)sel {
    UILabel *lbl  = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 150, 30)];
    lbl.text      = label;
    lbl.textColor = [UIColor whiteColor];
    [self.menuView addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(200, y, 50, 30)];
    [sw addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [self.menuView addSubview:sw];
}

- (void)toggleAimbot:(UISwitch *)s    { aimbotEnabled    = s.isOn; NSLog(@"[ModMenu] Aimbot: %@",    s.isOn?@"ON":@"OFF"); }
- (void)toggleSilentAim:(UISwitch *)s { silentAimEnabled = s.isOn; NSLog(@"[ModMenu] SilentAim: %@", s.isOn?@"ON":@"OFF"); }
- (void)toggleESP:(UISwitch *)s       { espEnabled       = s.isOn; NSLog(@"[ModMenu] ESP: %@",       s.isOn?@"ON":@"OFF"); }
- (void)toggleGodMode:(UISwitch *)s   { godModeEnabled   = s.isOn; NSLog(@"[ModMenu] GodMode: %@",   s.isOn?@"ON":@"OFF"); }

- (void)hideMenu   { self.menuView.hidden = YES; }
- (void)toggleMenu { self.menuView.hidden = !self.menuView.hidden; }

- (void)handlePan:(UIPanGestureRecognizer *)r {
    UIView *v  = r.view;
    CGPoint t  = [r translationInView:v.superview];
    v.center   = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [r setTranslation:CGPointZero inView:v.superview];
}

@end

// ==========================================
// PASSTHROUGH WINDOW — DESPUÉS de MenuController
// Ahora el compilador conoce .menuView correctamente
// ==========================================
@interface PassthroughWindow : UIWindow
@end

@implementation PassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];

    if (floatingBtn && hit == floatingBtn)
        return hit;

    if (menuCtrl && menuCtrl.menuView && !menuCtrl.menuView.hidden) {
        CGPoint pt = [menuCtrl.menuView convertPoint:point fromView:self];
        if ([menuCtrl.menuView pointInside:pt withEvent:event])
            return hit;
    }
    return nil;
}
@end

// ==========================================
// LÓGICA DEL HACK
// ==========================================
bool WorldToScreen(Vec3 worldPos, Vector2 &screenPos, Matrix4x4 viewProj) {
    float x = worldPos.x*viewProj.m[0][0] + worldPos.y*viewProj.m[1][0] + worldPos.z*viewProj.m[2][0] + viewProj.m[3][0];
    float y = worldPos.x*viewProj.m[0][1] + worldPos.y*viewProj.m[1][1] + worldPos.z*viewProj.m[2][1] + viewProj.m[3][1];
    float w = worldPos.x*viewProj.m[0][3] + worldPos.y*viewProj.m[1][3] + worldPos.z*viewProj.m[2][3] + viewProj.m[3][3];

    if (w < 0.01f) return false;

    float invW = 1.0f / w;
    x *= invW;
    y *= invW;

    CGRect bounds = GetScreenBounds();
    screenPos.x = (bounds.size.width  / 2.0f) + (x * bounds.size.width  / 2.0f);
    screenPos.y = (bounds.size.height / 2.0f) - (y * bounds.size.height / 2.0f);
    return true;
}

void HackLoop() {
    uintptr_t baseAddr = (uintptr_t)_dyld_get_image_header(0);
    CGRect    bounds   = GetScreenBounds();
    Vector2   center   = { (float)(bounds.size.width / 2.0f), (float)(bounds.size.height / 2.0f) };

    while (true) {
        if (aimbotEnabled || espEnabled || silentAimEnabled) {
            uintptr_t d3d11DevicePtr = *(uintptr_t*)(baseAddr + adrD3D11Device);
            uintptr_t objectsBasePtr = *(uintptr_t*)(baseAddr + adrObjects);
            uintptr_t localPlayerPtr = *(uintptr_t*)(baseAddr + OFF_LocalPlayer);

            if (d3d11DevicePtr && objectsBasePtr) {
                uintptr_t cameraInfoPtr = *(uintptr_t*)(d3d11DevicePtr + D3D11Device_CameraInfo);
                uintptr_t p1            = *(uintptr_t*)(objectsBasePtr  + ptrObject1);

                if (cameraInfoPtr && p1) {
                    CameraInfo *info    = (CameraInfo*)cameraInfoPtr;
                    GameVector *objects = (GameVector*)(p1 + ptrObject2);
                    int count = (int)((objects->End - objects->Begin) / sizeof(uintptr_t));

                    uintptr_t bestTarget = 0;
                    float     minDist    = 9999.0f;

                    if (count > 0 && count < 1000) {
                        for (int i = 0; i < count; i++) {
                            uintptr_t cur    = *(uintptr_t*)(objects->Begin + i * sizeof(uintptr_t));
                            if (!cur) continue;
                            uintptr_t entPtr = *(uintptr_t*)(cur - 0x10);
                            if (!entPtr) continue;

                            Entity *ent = (Entity*)entPtr;
                            if (ent->IsDead) continue;

                            Vector2 sp;
                            if (WorldToScreen(ent->Origin, sp, info->ViewProj)) {
                                float d = sqrtf(powf(sp.x - center.x, 2) + powf(sp.y - center.y, 2));
                                if (d < minDist) { minDist = d; bestTarget = entPtr; }
                            }
                        }
                    }

                    if (silentAimEnabled && bestTarget && localPlayerPtr) {
                        bool isShooting = *(bool*)(localPlayerPtr + OFF_sAim1);
                        if (isShooting) {
                            uintptr_t weaponData = *(uintptr_t*)(localPlayerPtr + OFF_sAim2);
                            if (weaponData) {
                                Entity *target  = (Entity*)bestTarget;
                                Vec3 targetHead = target->Origin;
                                targetHead.y   += 0.1f;
                                Vec3 startPos   = *(Vec3*)(weaponData + OFF_sAim3);
                                *(Vec3*)(weaponData + OFF_sAim4) = targetHead - startPos;
                            }
                        }
                    }
                }
            }
        }
        [NSThread sleepForTimeInterval:0.01];
    }
}

// ==========================================
// ENTRY POINT
// ==========================================
void SetupMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{

        UIWindowScene *scene = GetActiveWindowScene();

        if (scene) {
            menuWindow = [[PassthroughWindow alloc] initWithWindowScene:scene];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            menuWindow = [[PassthroughWindow alloc] initWithFrame:GetScreenBounds()];
#pragma clang diagnostic pop
        }

        menuWindow.windowLevel        = UIWindowLevelAlert + 1;
        menuWindow.backgroundColor    = [UIColor clearColor];
        menuCtrl                      = [[MenuController alloc] init];
        menuWindow.rootViewController = menuCtrl;
        [menuWindow makeKeyAndVisible];

        floatingBtn                    = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame              = CGRectMake(0, 100, 50, 50);
        floatingBtn.backgroundColor    = [UIColor redColor];
        floatingBtn.layer.cornerRadius = 25;
        [floatingBtn setTitle:@"M" forState:UIControlStateNormal];
        [floatingBtn addTarget:menuCtrl
                        action:@selector(toggleMenu)
              forControlEvents:UIControlEventTouchUpInside];

        UIPanGestureRecognizer *pan =
            [[UIPanGestureRecognizer alloc] initWithTarget:menuCtrl
                                                    action:@selector(handlePan:)];
        [floatingBtn addGestureRecognizer:pan];
        [menuWindow addSubview:floatingBtn];

        [NSThread detachNewThreadSelector:@selector(runHack)
                                 toTarget:[MenuController class]
                               withObject:nil];
    });
}

@interface MenuController (HackThread)
+ (void)runHack;
@end

@implementation MenuController (HackThread)
+ (void)runHack { HackLoop(); }
@end

__attribute__((constructor))
static void initialize() {
    NSLog(@"[ModMenu] Injected successfully!");
    SetupMenu();
}
