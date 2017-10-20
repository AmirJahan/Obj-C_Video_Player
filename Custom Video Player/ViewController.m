
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    AVPlayer *myPlayer;
    AVPlayerLayer* myPlayerLayer;
    
    NSURL *onlineUrl;
    NSURL *localURL;
    
    
    float currentRate;
    
    id timeObserver;

}
@property (weak, nonatomic) IBOutlet UIView *myContainerView;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;

@property (weak, nonatomic) IBOutlet UISlider *seekSlider;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;

@end

@implementation ViewController

static int myContext = 0;


- (IBAction)seekAction:(id)sender {
    float videoDur = CMTimeGetSeconds(myPlayer.currentItem.duration);
    CMTime newTime = CMTimeMake(_seekSlider.value * videoDur, 1);
    
    [self timeLeftAction: newTime];
}

-(IBAction)seekBegan:(UISlider *)slider {
    currentRate = myPlayer.rate;
    [myPlayer pause];
}

-(IBAction)seekEnded:(UISlider *)slider {
    float videoDur = CMTimeGetSeconds(myPlayer.currentItem.duration);
    CMTime newTime = CMTimeMake(_seekSlider.value * videoDur, 1);
    [self timeLeftAction: newTime];

    [myPlayer seekToTime:newTime completionHandler:^(BOOL finished) {
        [myPlayer play];
    }];
}


- (IBAction)playPuseAction:(id)sender {

    if ( myPlayer.rate > 0)
        [myPlayer pause];
    else
        [myPlayer play];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];

    onlineUrl = [[NSURL alloc] initWithString:@"http://ajcut.com/wp-content/uploads/2014/06/AmirJahanlouReel.mp4"];
    localURL = [[NSBundle mainBundle] URLForResource:@"ANTI" withExtension:@"mp4"];
    
    
    myPlayer = [AVPlayer playerWithURL: localURL];


    myPlayerLayer = [AVPlayerLayer playerLayerWithPlayer: myPlayer];
    
    // UIKIt is with UICOlor
    // Layers are with CGCOlor
    // Anything with layers, we use CGCOlor
    myPlayerLayer.backgroundColor = [[UIColor lightGrayColor] CGColor];
    
    
    
    [_myContainerView.layer addSublayer:myPlayerLayer];
    
    
    // https://developer.apple.com/documentation/coremedia/cmtime-u58
//    CMTime t1 = CMTimeMake(1, 10); // 1/10 second = 0.1 second
//    CMTime t2 = CMTimeMake(2, 1);  // 2 seconds
    
    CMTime timeInterval = CMTimeMake(1.0, 10);
    
    __weak typeof(self) weakSelf = self;
    
    timeObserver = [myPlayer addPeriodicTimeObserverForInterval:timeInterval
                                           queue:NULL
                                      usingBlock:^(CMTime time)
    {
        [weakSelf timeLeftAction: time];
    }];


    _actIndicator.hidesWhenStopped = true;
    
    
    // https://developer.apple.com/documentation/foundation/notifications/nskeyvalueobserving
    [myPlayer addObserver:self
               forKeyPath:@"playbackLikelyToKeepUp"
                  options:NSKeyValueObservingOptionNew
                  context:&myContext];

}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if(context == &myContext)
    {
        if (myPlayer.currentItem.playbackLikelyToKeepUp)
            [_actIndicator stopAnimating];
        else
            [_actIndicator startAnimating];
    }
}
-(void)timeLeftAction:(CMTime)passedTime
{
    float duration = CMTimeGetSeconds(myPlayer.currentItem.duration);
    float timeLeft = duration - CMTimeGetSeconds(passedTime);
    
    _timeLeftLabel.text = [NSString stringWithFormat: @"%.4f", timeLeft];
}


-(void)dealloc
{
    [myPlayer removeTimeObserver:timeObserver];
}

-(void)anotherTrack
{
    AVPlayerItem *myItem = [AVPlayerItem playerItemWithURL:onlineUrl];
    [myPlayer replaceCurrentItemWithPlayerItem:myItem];
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:true];
    
    [_actIndicator startAnimating];
    
    myPlayerLayer.frame = _myContainerView.bounds;
    [myPlayer play];
}

@end
