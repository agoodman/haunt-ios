//
//  SettingsViewController.h
//  Haunt
//
//  Created by Aubrey Goodman on 7/16/12.
//  Copyright (c) 2012 Migrant Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController {
    
    IBOutlet UISwitch* hauntEnabled;
    IBOutlet UIProgressView* progressView;
    IBOutlet UITextView* captionView;
    
}

@end
