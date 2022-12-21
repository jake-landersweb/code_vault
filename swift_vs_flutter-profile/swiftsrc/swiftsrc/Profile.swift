//
//  Profile.swift
//  swiftsrc
//
//  Created by Jake Landers on 12/20/22.
//

import SwiftUI

struct Profile: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                avatar
                Spacer()
                stats
                Spacer()
            }
            VStack(alignment: .leading) {
                Text("Jake Landers")
                    .foregroundColor(.white)
                    .font(.system(size: 42, weight: .semibold))
                Text("Developer and Creator at SapphireNW")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 18, weight: .semibold))
            }
            Text("Latest Posts")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .semibold))
                .padding(.top, 16)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bgColor)
    }
    
    var avatar: some View {
        ZStack {
            Image("jake")
                .resizable()
                .frame(width: 125, height: 125)
                .clipShape(Circle())
            // zstack with background circle to add a rounded border
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 135, height: 135)
        }
    }
    
    var stats: some View {
        HStack(spacing: 32) {
            VStack {
                Text("140")
                    .font(.system(size: 24))
                Text("Following")
            }
            VStack {
                Text("237")
                    .font(.system(size: 24))
                Text("Followers")
            }
        }
        .foregroundColor(.white)
    }
    
    var content: some View {
        VStack(spacing: 8) {
            ForEach(0..<3, id:\.self) { i in
                HStack(spacing: 8) {
                    ForEach(0..<3, id:\.self) { j in
                        Rectangle()
                            .fill(bgColorAccent)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile()
    }
}

