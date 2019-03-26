//
//  TWFileStream.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/25/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#include "TWFileStream.h"
#include "TWHeader.h"


TWFileStream::TWFileStream()
{
    _leftBuffer = new TWRingBuffer(kAudioFileReadBufferSize);
    _rightBuffer = new TWRingBuffer(kAudioFileReadBufferSize);
    
    _sampleRate = kDefaultSampleRate;
    _isRunning = false;
    _audioFile = nullptr;
    _currentSample = 0;
    _samplesRead = 0;
}

TWFileStream::~TWFileStream()
{
    delete _leftBuffer;
    delete _rightBuffer;
    
    _leftBuffer = nullptr;
    _rightBuffer = nullptr;
}

void TWFileStream::prepare(float sampleRate)
{
    _sampleRate = sampleRate;
}

void TWFileStream::getSample(float& leftSample, float& rightSample)
{
    if (!_isRunning) {
//        leftSample = rightSample = 0.0f;
        return;
    }
    
    leftSample += _leftBuffer->readAndIncIdx();
    rightSample += _rightBuffer->readAndIncIdx();
    
//    printf("\nReadIdx: %d", _leftBuffer->getReadIdx());
//    if (_currentSample == (_samplesRead / 2)) {
//
//    }
    _currentSample += 1;
}

void TWFileStream::release()
{
    
}

void TWFileStream::setReadQueue(dispatch_queue_t readQueue)
{
    _readQueue = readQueue;
}

int TWFileStream::loadAudioFile(std::string filepath)
{
    if (_isRunning) {
        stop();
    }
    
    if (_audioFile) {
        _resetAudioFile();
    }
    
    
    CFStringRef string = CFStringCreateWithCString(kCFAllocatorDefault, filepath.c_str(), kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, string, NULL);
    
    OSStatus status = ExtAudioFileOpenURL(url, &_audioFile);
    
    CFRelease(url);
    CFRelease(string);
    
    if ((status != noErr) || (_audioFile == NULL)) {
        printf("\nError in ExtAudioFileOpenURL (%s) : %d", filepath.c_str(), (unsigned int)status);
        _resetAudioFile();
        return -1;
    }
    
    
    
    AudioStreamBasicDescription outASBD;
    outASBD.mSampleRate = _sampleRate;
    outASBD.mFormatID = kAudioFormatLinearPCM;
    outASBD.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;
    outASBD.mBitsPerChannel = 32;
    outASBD.mChannelsPerFrame = 2;
    outASBD.mBytesPerFrame = outASBD.mChannelsPerFrame * 4;
    outASBD.mFramesPerPacket = 1;
    outASBD.mBytesPerPacket = outASBD.mFramesPerPacket * outASBD.mBytesPerFrame;
    _printASBD(&outASBD, "TWFileStream: Out ASBD");
    
    status = ExtAudioFileSetProperty(_audioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(outASBD), &outASBD);
    if (status) {
        printf("\nError in setting kExtAudioFileProperty_ClientDataFormat : %d", (unsigned int)status);
        _resetAudioFile();
        return -2;
    }
    
    
    
    AudioStreamBasicDescription inASBD;
    UInt32 propSize = sizeof(inASBD);
    status = ExtAudioFileGetProperty(_audioFile, kExtAudioFileProperty_FileDataFormat, &propSize, &inASBD);
    if (status) {
        printf("\nError in reading kExtAudioFileProperty_FileDataFormat : %d", (unsigned int)status);
        _resetAudioFile();
    }
    _printASBD(&outASBD, "TWFileStream: inFileASBD");
    
    
    
    SInt64 length = 0;
    propSize = sizeof(SInt64);
    status = ExtAudioFileGetProperty(_audioFile, kExtAudioFileProperty_FileLengthFrames, &propSize, &length);
    if (status) {
        printf("\nError in reading kExtAudioFileProperty_FileLengthFrames : %d", (unsigned int)status);
        _resetAudioFile();
        return -3;
    }
    if (length <= 0) {
        printf("\nError in reading kExtAudioFileProperty_FileLengthFrames : length: %lld", length);
        _resetAudioFile();
        return -4;
    }
    
    _leftBuffer->reset();
    _rightBuffer->reset();
    _readNextBlock();
//    _readNextBlock();
    
    _length = length;
    _currentSample = 0;
    printf("\nLoaded Audio File (%s) with %lld (of %lld) samples.\n\n", filepath.c_str(), (unsigned long long)_samplesRead, (unsigned long long)_length);
    
    return 0;
}


int TWFileStream::start(uint64_t startSampleTime)
{
    _leftBuffer->setReadIdx((int)startSampleTime);
    _rightBuffer->setReadIdx((int)startSampleTime);
    _isRunning = true;
//    printf("\nStart!");
    return 0;
}

void TWFileStream::stop()
{
    _isRunning = false;
//    printf("\nStop!");
}

void TWFileStream::setLooping(bool isLooping)
{
    _isLooping = isLooping;
}

bool TWFileStream::getLooping()
{
    return _isLooping;
}

bool TWFileStream::getIsRunning()
{
    return _isRunning;
}

float TWFileStream::getNormalizedPlaybackProgress()
{
    return 0.0f;
}




void TWFileStream::_printASBD(AudioStreamBasicDescription* asbd, std::string context) {
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

void TWFileStream::_printABL(AudioBufferList *abl, std::string context)
{
    printf("\nABL (%s):", context.c_str());
    printf("\nmNumBuffers: %d", abl->mNumberBuffers);
    for (int buffer=0; buffer < abl->mNumberBuffers; buffer++) {
        printf("\nBuffer[%d]. mNumChannels: %d, mDataByteSize: %d", buffer, abl->mBuffers[buffer].mNumberChannels, abl->mBuffers[buffer].mDataByteSize);
    }
    printf("\n");
}


AudioBufferList* TWFileStream::_allocateABL(UInt32 channelsPerFrame, UInt32 bytesPerFrame, bool interleaved, UInt32 capacityFrames)
{
    AudioBufferList *bufferList = NULL;
    
    UInt32 numBuffers = interleaved ? 1 : channelsPerFrame;
    UInt32 channelsPerBuffer = interleaved ? channelsPerFrame : 1;
    
    bufferList = static_cast<AudioBufferList*>(calloc(1, offsetof(AudioBufferList, mBuffers) + (sizeof(AudioBuffer) * numBuffers)));
    
    bufferList->mNumberBuffers = numBuffers;
    
    for(UInt32 bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; ++bufferIndex) {
        bufferList->mBuffers[bufferIndex].mData = static_cast<void *>(calloc(capacityFrames, bytesPerFrame));
        bufferList->mBuffers[bufferIndex].mDataByteSize = capacityFrames * bytesPerFrame;
        bufferList->mBuffers[bufferIndex].mNumberChannels = channelsPerBuffer;
    }
    
    return bufferList;
}

void TWFileStream::_deallocateABL(AudioBufferList* abl)
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


void TWFileStream::_readNextBlock()
{
    dispatch_async(_readQueue, ^{
        
        UInt32 ablSize = kAudioFileReadBufferSize;
        AudioBufferList* abl = _allocateABL(kNumChannels, kNumChannels * 4, true, ablSize);
        _printABL(abl, "read");
        
        UInt32 framesRead = ablSize;
        OSStatus status = ExtAudioFileRead(_audioFile, &framesRead, abl);
        if (status) {
            printf("\nError in ExtAudioFileRead. Error: %d", status);
            _resetAudioFile();
        } else {
            _samplesRead += framesRead;
            printf("\nFrames read : %lu", (unsigned long)framesRead);
            float* buffer = (float*)abl->mBuffers[0].mData;
            for (int i=0; i < framesRead; i++) {
                if ((i % 2) == 0) {
                    _leftBuffer->writeAndIncIdx(buffer[i]);
                } else {
                    _rightBuffer->writeAndIncIdx(buffer[i]);
                }
            }
        }
        
        _deallocateABL(abl);
    });
}

void TWFileStream::_resetAudioFile()
{
    ExtAudioFileDispose(_audioFile);
    _audioFile = NULL;
    _length = 0;
    _currentSample = 0;
    _samplesRead = 0;
}
