#import "MRAdView.h"
#import "MPAdDestinationDisplayAgent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MRAdViewSpec)

describe(@"MRAdView", ^{
    __block MRAdView *view;
    __block id<CedarDouble, MRAdViewDelegate> delegate;
    __block MPAdDestinationDisplayAgent<CedarDouble> *destinationDisplayAgent;
    __block UIViewController *presentingViewController;
    __block UIWindow *window;

    beforeEach(^{
        destinationDisplayAgent = nice_fake_for([MPAdDestinationDisplayAgent class]);
        fakeProvider.fakeMPAdDestinationDisplayAgent = destinationDisplayAgent;

        presentingViewController = [[[UIViewController alloc] init] autorelease];

        view = [[[MRAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
        delegate = nice_fake_for(@protocol(MRAdViewDelegate));
        delegate stub_method("viewControllerForPresentingModalView").and_return(presentingViewController);
        view.delegate = delegate;

        window = [[[UIWindow alloc] init] autorelease];
        [window makeKeyAndVisible];
    });

    afterEach(^{
        [window resignKeyWindow];
    });

    describe(@"when performing URL navigation", ^{
        __block NSURL *URL;

        context(@"when the scheme is mopub://", ^{
            it(@"should not load anything", ^{
                URL = [NSURL URLWithString:@"mopub://close"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
            });
        });

        context(@"when the scheme is ios-log://", ^{
            it(@"should not load anything", ^{
                URL = [NSURL URLWithString:@"ios-log://something.to.be.printed"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
            });
        });

        context(@"when the creative hasn't finished loading", ^{
            beforeEach(^{
                NSString *HTMLString = @"<h1>Hi, dudes!</h1>";
                [view loadCreativeWithHTMLString:HTMLString baseURL:nil];
            });

            it(@"should load the URL in the webview", ^{
                URL = [NSURL URLWithString:@"http://www.donuts.com"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
            });

            context(@"when the creative finishes loading", ^{
                __block NSMutableURLRequest *request;
                beforeEach(^{
                    URL = [NSURL URLWithString:@"http://www.donuts.com"];
                    request = [NSMutableURLRequest requestWithURL:URL];
                    request.mainDocumentURL = URL;
                    [view webViewDidFinishLoad:nil];
                });

                context(@"when the navigation type is other", ^{
                    it(@"should ask the destination display agent to load the URL", ^{
                        [view webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                        destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
                    });
                });

                context(@"when the navigation type is clicked", ^{
                    it(@"should ask the destination display agent to load the URL", ^{
                        [view webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
                        destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
                    });
                });

                context(@"when the requested URL is an iframe", ^{
                    it(@"should not ask the destionation display agent to load the URL", ^{
                        NSURL *documentURL = [NSURL URLWithString:@"http://www.donuts.com"];
                        NSURL *iframeURL = [NSURL URLWithString:@"http://www.jelly.com"];
                        NSMutableURLRequest *iframeURLRequest = [NSMutableURLRequest requestWithURL:iframeURL];
                        iframeURLRequest.mainDocumentURL = documentURL;
                        [view webView:nil shouldStartLoadWithRequest:iframeURLRequest navigationType:UIWebViewNavigationTypeOther] should equal(YES);
                        destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                    });
                });

                context(@"when the navigation type is anything else", ^{
                    it(@"should ask the destination display agent to load the URL", ^{
                        [view webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeReload] should equal(YES);
                        destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                    });
                });
            });
        });
    });

    describe(@"mraid://open", ^{
        context(@"when the ad is in the default state", ^{
            it(@"should ask the destination display agent to load the URL", ^{
                NSURL *URL = [NSURL URLWithString:@"http://www.donuts.com"];
                [view handleMRAIDOpenCallForURL:URL];
                destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
            });
        });

        context(@"when the ad is in the expanded state", ^{
            __block NSURL *URL;

            beforeEach(^{
                NSURL *expandCommandURL = [NSURL URLWithString:@"mraid://expand"];
                NSURLRequest *expandRequest = [NSURLRequest requestWithURL:expandCommandURL];
                [view webView:nil
                      shouldStartLoadWithRequest:expandRequest
                      navigationType:UIWebViewNavigationTypeOther];
                [[[UIApplication sharedApplication] keyWindow] subviews] should contain(view);

                // XXX: Expansion has some async animation behavior, which we'll have to fix to
                // avoid this type of ugly hack.
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5]];

                URL = [NSURL URLWithString:@"http://www.donuts.com"];
                [view handleMRAIDOpenCallForURL:URL];
            });

            it(@"should ask the destination display agent to load the URL", ^{
                destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
            });

            context(@"when the destination display agent presents a modal view controller", ^{
                beforeEach(^{
                    [view displayAgentWillPresentModal];
                });

                it(@"should temporarily hide the expanded ad", ^{
                    [[[UIApplication sharedApplication] keyWindow] subviews] should contain(view);
                    view.hidden should equal(YES);
                });

                context(@"when the modal view controller is dismissed", ^{
                    beforeEach(^{
                        [view displayAgentDidDismissModal];
                    });

                    it(@"should un-hide the expanded ad", ^{
                        view.hidden should equal(NO);
                    });

                    it(@"should not tell the delegate that the ad has been dismissed", ^{
                        delegate should_not have_received(@selector(appShouldResumeFromAd:));
                    });
                });
            });
        });
    });

    describe(@"MPAdDestinationDisplayAgentDelegate", ^{
        context(@"when asked for a view controller to present modal views", ^{
            it(@"should ask the MRAdViewDelegate for one", ^{
                [view viewControllerForPresentingModalView] should equal(presentingViewController);
            });
        });

        context(@"when a modal is presented", ^{
            beforeEach(^{
                [view displayAgentWillPresentModal];
            });

            it(@"should tell the delegate", ^{
                delegate should have_received(@selector(appShouldSuspendForAd:)).with(view);
            });

            context(@"when the modal is dismissed", ^{
                it(@"should tell the delegate", ^{
                    [view displayAgentDidDismissModal];
                    delegate should have_received(@selector(appShouldResumeFromAd:)).with(view);
                });
            });
        });
    });
});

SPEC_END
