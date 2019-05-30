//
//  TWAudioUtilities.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 5/9/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWAudioUtilities_h
#define TWAudioUtilities_h

#include <stdio.h>
#include <string>
#include <CoreAudio/CoreAudioTypes.h>

class TWAudioUtilities {
    
public:
    
    static bool CheckOSStatus(OSStatus status, std::string context);
    
    static float Linear2DB(float inLinearValue);
    static float DB2Linear(float inDBValue);
    
    static float Max(float a, float b);
    static float Min(float a, float b);
    
    static float MinLevelDB();
    
    static AudioBufferList* AllocateABL(UInt32 channelsPerFrame, UInt32 bytesPerFrame, bool isInterleaved, UInt32 capacityFrames);
    static void DeallocateABL(AudioBufferList* abl);
    static void PrintABL(AudioBufferList *abl, std::string context);
    static void PrintASBD(AudioStreamBasicDescription* asbd, std::string context);

};
#endif /* TWAudioUtilities_h */
