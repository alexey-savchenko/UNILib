//
//  CMTime+Ext.swift
//  call_recorder
//
//  Created by Alexey Savchenko on 07.09.2020.
//  Copyright © 2020 Universe. All rights reserved.
//

import AVFoundation

public func - (lhs: CMTime, rhs: Double) -> CMTime {
  return CMTimeMakeWithSeconds(lhs.seconds - rhs, preferredTimescale: lhs.timescale)
}

public func + (lhs: CMTime, rhs: Double) -> CMTime {
  return CMTimeMakeWithSeconds(lhs.seconds + rhs, preferredTimescale: lhs.timescale)
}

public func / (lhs: CMTime, rhs: Double) -> CMTime {
  return CMTimeMakeWithSeconds(lhs.seconds / rhs, preferredTimescale: lhs.timescale)
}

public func * (lhs: CMTime, rhs: Double) -> CMTime {
  return CMTimeMakeWithSeconds(lhs.seconds * rhs, preferredTimescale: lhs.timescale)
}
