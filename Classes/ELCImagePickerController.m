//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
//#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"

@implementation ELCImagePickerController

@synthesize delegate;

-(void)cancelImagePicker {
	if([delegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[delegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

-(void)updateInterface:(NSArray*)returnArray{
    
    [self popToRootViewControllerAnimated:NO];
    
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
    
	if([delegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[delegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:[NSArray arrayWithArray:returnArray]];
	}
}

-(void)calculateDictionary:(NSArray*)_assets{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];

	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for(ALAsset *asset in _assets) {
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		[workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
        [workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
		[workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
		
		[returnArray addObject:workingDictionary];
		
		[workingDictionary release];	
    }
    [self performSelectorOnMainThread:@selector(updateInterface:) withObject:returnArray waitUntilDone:YES];
    [returnArray release];
    [pool release];
}

-(void)selectedAssets:(NSArray*)_assets {
    [NSThread detachNewThreadSelector:@selector(calculateDictionary:) toTarget:self withObject:_assets];    
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {    
    NSLog(@"ELC Image Picker received memory warning.");
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}

@end
