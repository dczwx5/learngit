/****************************************************************************
 Copyright (c) 2018 Xiamen Yaji Software Co., Ltd.

 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/


#pragma once


#include <vector>
#include "../Macro.h"
#include "../Types.h"
#include "GraphicsHandle.h"

RENDERER_BEGIN

class DeviceGraphics;
class RenderTarget;

class FrameBuffer final : public GraphicsHandle
{
public:
    RENDERER_DEFINE_CREATE_METHOD_3(FrameBuffer, init,  DeviceGraphics*, uint16_t, uint16_t)

    FrameBuffer();
    bool init(DeviceGraphics* device, uint16_t width, uint16_t height);
    void destroy();

    void setColorBuffers(const std::vector<RenderTarget*>& renderTargets);
    void setColorBuffer(RenderTarget* rt, int index);
    void setDepthBuffer(RenderTarget* rt);
    void setStencilBuffer(RenderTarget* rt);
    void setDepthStencilBuffer(RenderTarget* rt);
    
    const std::vector<RenderTarget*>& getColorBuffers() const;
    const RenderTarget* getDepthBuffer() const;
    const RenderTarget* getStencilBuffer() const;
    const RenderTarget* getDepthStencilBuffer() const;

private:
    virtual ~FrameBuffer();

    DeviceGraphics* _device;
    std::vector<RenderTarget*> _colorBuffers;
    RenderTarget* _depthBuffer;
    RenderTarget* _stencilBuffer;
    RenderTarget* _depthStencilBuffer;
    uint16_t _width;
    uint16_t _height;
};

RENDERER_END
