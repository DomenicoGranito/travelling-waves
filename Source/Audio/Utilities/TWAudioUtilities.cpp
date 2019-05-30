//
//  TWAudioUtilities.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 5/9/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#include "TWAudioUtilities.h"
#include <math.h>


static const float  kMinLevelDB = -144.0f;

bool TWAudioUtilities::CheckOSStatus(int status, std::string context)
{
    bool success = true;
    
    if (status != noErr) {
        printf("\nError in %s: %d", context.c_str(), status);
        success = false;
    }
    
    return success;
}



float TWAudioUtilities::Linear2DB(float inLinearValue)
{
    return (20.0f * log10f(inLinearValue));
}

float TWAudioUtilities::DB2Linear(float inDBValue)
{
    return powf(10.0f, (inDBValue / 20.0f));
}


float TWAudioUtilities::Max(float a, float b)
{
    return (a > b) ? a : b;
}

float TWAudioUtilities::Min(float a, float b)
{
    return (a < b) ? a : b;
}




AudioBufferList* TWAudioUtilities::AllocateABL(UInt32 channelsPerFrame, UInt32 bytesPerFrame, bool isInterleaved, UInt32 capacityFrames)
{
    AudioBufferList *bufferList = nullptr;
    
    UInt32 numBuffers = isInterleaved ? 1 : channelsPerFrame;
    UInt32 channelsPerBuffer = isInterleaved ? channelsPerFrame : 1;
    
    bufferList = static_cast<AudioBufferList*>(calloc(1, offsetof(AudioBufferList, mBuffers) + (sizeof(AudioBuffer) * numBuffers)));
    
    bufferList->mNumberBuffers = numBuffers;
    
    for(UInt32 bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; ++bufferIndex) {
        bufferList->mBuffers[bufferIndex].mData = static_cast<void *>(calloc(capacityFrames, bytesPerFrame));
        bufferList->mBuffers[bufferIndex].mDataByteSize = capacityFrames * bytesPerFrame;
        bufferList->mBuffers[bufferIndex].mNumberChannels = channelsPerBuffer;
    }
    
    return bufferList;
}

void TWAudioUtilities::DeallocateABL(AudioBufferList *abl)
{
    if (abl == nullptr) {
        return;
    }
    for (UInt32 bufferIdx=0; bufferIdx < abl->mNumberBuffers; bufferIdx++) {
        if (abl->mBuffers[bufferIdx].mData != nullptr) {
            free(abl->mBuffers[bufferIdx].mData);
        }
    }
    free(abl);
    abl = nullptr;
}



float TWAudioUtilities::MinLevelDB()
{
    return kMinLevelDB;
}



//AudioBufferList* TWMemoryPlayer::_allocateABL(UInt32 channelsPerFrame, UInt32 bytesPerFrame, bool interleaved, UInt32 capacityFrames)
//{
//    AudioBufferList *bufferList = NULL;
//
//    UInt32 numBuffers = interleaved ? 1 : channelsPerFrame;
//    UInt32 channelsPerBuffer = interleaved ? channelsPerFrame : 1;
//
//    bufferList = static_cast<AudioBufferList*>(calloc(1, offsetof(AudioBufferList, mBuffers) + (sizeof(AudioBuffer) * numBuffers)));
//
//    bufferList->mNumberBuffers = numBuffers;
//
//    for(UInt32 bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; ++bufferIndex) {
//        bufferList->mBuffers[bufferIndex].mData = static_cast<void *>(calloc(capacityFrames, bytesPerFrame));
//        bufferList->mBuffers[bufferIndex].mDataByteSize = capacityFrames * bytesPerFrame;
//        bufferList->mBuffers[bufferIndex].mNumberChannels = channelsPerBuffer;
//    }
//
//    return bufferList;
//}
//
//void TWMemoryPlayer::_deallocateABL(AudioBufferList* abl)
//{
//    if (abl == nullptr) {
//        return;
//    }
//
//    for (UInt32 bufferIdx=0; bufferIdx < abl->mNumberBuffers; bufferIdx++) {
//        if (abl->mBuffers[bufferIdx].mData != nullptr) {
//            free(abl->mBuffers[bufferIdx].mData);
//        }
//    }
//    free(abl);
//    abl = nullptr;
//}


void TWAudioUtilities::PrintASBD(AudioStreamBasicDescription* asbd, std::string context)
{
    printf("\nASBD (%s): ", context.c_str());
    printf("\nmSampleRate: %f",  asbd->mSampleRate);
    printf("\nmFormatID: %u",  (unsigned int)asbd->mFormatID);
    printf("\nmFormatFlags: %u",  (unsigned int)asbd->mFormatFlags);
    printf("\nmBitsPerChannel: %d",  asbd->mBitsPerChannel);
    printf("\nmChannelsPerFrame: %d",  asbd->mChannelsPerFrame);
    printf("\nmBytesPerFrame: %d",  asbd->mBytesPerFrame);
    printf("\nmFramesPerPacket: %d",  asbd->mFramesPerPacket);
    printf("\nmBytesPerPacket: %d",  asbd->mBytesPerPacket);
    printf("\n");
}

void TWAudioUtilities::PrintABL(AudioBufferList *abl, std::string context)
{
    printf("\nABL (%s):", context.c_str());
    printf("\nmNumBuffers: %d", abl->mNumberBuffers);
    for (int buffer=0; buffer < abl->mNumberBuffers; buffer++) {
        printf("\nBuffer[%d]. mNumChannels: %d, mDataByteSize: %d", buffer, abl->mBuffers[buffer].mNumberChannels, abl->mBuffers[buffer].mDataByteSize);
    }
    printf("\n");
}
