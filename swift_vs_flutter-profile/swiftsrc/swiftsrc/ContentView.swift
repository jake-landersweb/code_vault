//
//  ContentView.swift
//  swiftsrc
//
//  Created by Jake Landers on 12/20/22.
//

import SwiftUI

let mainColor = Color(red: 137/255, green: 107/255, blue: 255/255);
let bgColor = Color(red: 14/255, green: 18/255, blue: 25/255);
let bgColorAccent = Color(red: 20/255, green: 25/255, blue: 32/255);

struct ContentView: View {
    var body: some View {
        Profile()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
