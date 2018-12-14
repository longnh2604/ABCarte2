//
//  SyllabaryPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/06.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol SyllabaryPopupVCDelegate: class {
    func onSyllabarySearch(characters:[String])
}

class SyllabaryPopupVC: UIViewController {

    //Variable
    weak var delegate:SyllabaryPopupVCDelegate?
    
    var alphaSelect = [Int]()
    var alphabetDict : [Int: String] = [1:"あ",
                                        2:"い",
                                        3:"う",
                                        4:"え",
                                        5:"お",
                                        6:"か",
                                        7:"き",
                                        8:"く",
                                        9:"け",
                                        10:"こ",
                                        11:"さ",
                                        12:"し",
                                        13:"す",
                                        14:"せ",
                                        15:"そ",
                                        16:"た",
                                        17:"ち",
                                        18:"つ",
                                        19:"て",
                                        20:"と",
                                        21:"な",
                                        22:"に",
                                        23:"ぬ",
                                        24:"ね",
                                        25:"の",
                                        26:"は",
                                        27:"ひ",
                                        28:"ふ",
                                        29:"へ",
                                        30:"ほ",
                                        31:"ま",
                                        32:"み",
                                        33:"む",
                                        34:"め",
                                        35:"も",
                                        36:"や",
                                        37:"ゆ",
                                        38:"よ",
                                        39:"ら",
                                        40:"り",
                                        41:"る",
                                        42:"れ",
                                        43:"ろ",
                                        44:"わ",
                                        45:"を",
                                        46:"ん",
                                        51:"A",
                                        52:"B",
                                        53:"C",
                                        54:"D",
                                        55:"E",
                                        56:"F",
                                        57:"G",
                                        58:"H",
                                        59:"I",
                                        60:"J",
                                        61:"K",
                                        62:"L",
                                        63:"M",
                                        64:"N",
                                        65:"O",
                                        66:"P",
                                        67:"Q",
                                        68:"R",
                                        69:"S",
                                        70:"T",
                                        71:"U",
                                        72:"V",
                                        73:"W",
                                        74:"X",
                                        75:"Y",
                                        76:"Z"
    ]
    
    //Japanese Alphabet
    @IBOutlet weak var a: RoundButton!
    @IBOutlet weak var i: RoundButton!
    @IBOutlet weak var u: RoundButton!
    @IBOutlet weak var e: RoundButton!
    @IBOutlet weak var o: RoundButton!
    @IBOutlet weak var ka: RoundButton!
    @IBOutlet weak var ki: RoundButton!
    @IBOutlet weak var ku: RoundButton!
    @IBOutlet weak var ke: RoundButton!
    @IBOutlet weak var ko: RoundButton!
    @IBOutlet weak var sa: RoundButton!
    @IBOutlet weak var shi: RoundButton!
    @IBOutlet weak var su: RoundButton!
    @IBOutlet weak var se: RoundButton!
    @IBOutlet weak var so: RoundButton!
    @IBOutlet weak var ta: RoundButton!
    @IBOutlet weak var chi: RoundButton!
    @IBOutlet weak var tsu: RoundButton!
    @IBOutlet weak var te: RoundButton!
    @IBOutlet weak var to: RoundButton!
    @IBOutlet weak var na: RoundButton!
    @IBOutlet weak var ni: RoundButton!
    @IBOutlet weak var nu: RoundButton!
    @IBOutlet weak var ne: RoundButton!
    @IBOutlet weak var no: RoundButton!
    @IBOutlet weak var ha: RoundButton!
    @IBOutlet weak var hi: RoundButton!
    @IBOutlet weak var fu: RoundButton!
    @IBOutlet weak var he: RoundButton!
    @IBOutlet weak var ho: RoundButton!
    @IBOutlet weak var ma: RoundButton!
    @IBOutlet weak var mi: RoundButton!
    @IBOutlet weak var mu: RoundButton!
    @IBOutlet weak var me: RoundButton!
    @IBOutlet weak var mo: RoundButton!
    @IBOutlet weak var ya: RoundButton!
    @IBOutlet weak var yu: RoundButton!
    @IBOutlet weak var yo: RoundButton!
    @IBOutlet weak var ra: RoundButton!
    @IBOutlet weak var ri: RoundButton!
    @IBOutlet weak var ru: RoundButton!
    @IBOutlet weak var re: RoundButton!
    @IBOutlet weak var ro: RoundButton!
    @IBOutlet weak var wa: RoundButton!
    @IBOutlet weak var wo: RoundButton!
    @IBOutlet weak var n: RoundButton!
    
    //Eng Alphabet
    @IBOutlet weak var AA: RoundButton!
    @IBOutlet weak var BB: RoundButton!
    @IBOutlet weak var CC: RoundButton!
    @IBOutlet weak var DD: RoundButton!
    @IBOutlet weak var EE: RoundButton!
    @IBOutlet weak var FF: RoundButton!
    @IBOutlet weak var GG: RoundButton!
    @IBOutlet weak var HH: RoundButton!
    @IBOutlet weak var II: RoundButton!
    @IBOutlet weak var JJ: RoundButton!
    @IBOutlet weak var KK: RoundButton!
    @IBOutlet weak var LL: RoundButton!
    @IBOutlet weak var MM: RoundButton!
    @IBOutlet weak var NN: RoundButton!
    @IBOutlet weak var OO: RoundButton!
    @IBOutlet weak var PP: RoundButton!
    @IBOutlet weak var QQ: RoundButton!
    @IBOutlet weak var RR: RoundButton!
    @IBOutlet weak var SS: RoundButton!
    @IBOutlet weak var TT: RoundButton!
    @IBOutlet weak var UU: RoundButton!
    @IBOutlet weak var VV: RoundButton!
    @IBOutlet weak var WW: RoundButton!
    @IBOutlet weak var XX: RoundButton!
    @IBOutlet weak var YY: RoundButton!
    @IBOutlet weak var ZZ: RoundButton!
    
    @IBOutlet weak var rowA: RoundButton!
    @IBOutlet weak var rowKA: RoundButton!
    @IBOutlet weak var rowSA: RoundButton!
    @IBOutlet weak var rowTA: RoundButton!
    @IBOutlet weak var rowNA: RoundButton!
    @IBOutlet weak var rowHA: RoundButton!
    @IBOutlet weak var rowMA: RoundButton!
    @IBOutlet weak var rowYA: RoundButton!
    @IBOutlet weak var rowRA: RoundButton!
    @IBOutlet weak var rowWA: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        unSelectedAll()
    }
   
    func unSelectedAll() {
        rowA.alpha = 0.5
        rowKA.alpha = 0.5
        rowSA.alpha = 0.5
        rowTA.alpha = 0.5
        rowNA.alpha = 0.5
        rowHA.alpha = 0.5
        rowMA.alpha = 0.5
        rowYA.alpha = 0.5
        rowRA.alpha = 0.5
        rowWA.alpha = 0.5
        
        a.backgroundColor = UIColor.clear
        i.backgroundColor = UIColor.clear
        u.backgroundColor = UIColor.clear
        e.backgroundColor = UIColor.clear
        o.backgroundColor = UIColor.clear
        ka.backgroundColor = UIColor.clear
        ki.backgroundColor = UIColor.clear
        ku.backgroundColor = UIColor.clear
        ke.backgroundColor = UIColor.clear
        ko.backgroundColor = UIColor.clear
        sa.backgroundColor = UIColor.clear
        shi.backgroundColor = UIColor.clear
        su.backgroundColor = UIColor.clear
        se.backgroundColor = UIColor.clear
        so.backgroundColor = UIColor.clear
        ta.backgroundColor = UIColor.clear
        chi.backgroundColor = UIColor.clear
        tsu.backgroundColor = UIColor.clear
        te.backgroundColor = UIColor.clear
        to.backgroundColor = UIColor.clear
        na.backgroundColor = UIColor.clear
        ni.backgroundColor = UIColor.clear
        nu.backgroundColor = UIColor.clear
        ne.backgroundColor = UIColor.clear
        no.backgroundColor = UIColor.clear
        ha.backgroundColor = UIColor.clear
        hi.backgroundColor = UIColor.clear
        fu.backgroundColor = UIColor.clear
        he.backgroundColor = UIColor.clear
        ho.backgroundColor = UIColor.clear
        ma.backgroundColor = UIColor.clear
        mi.backgroundColor = UIColor.clear
        mu.backgroundColor = UIColor.clear
        me.backgroundColor = UIColor.clear
        mo.backgroundColor = UIColor.clear
        ya.backgroundColor = UIColor.clear
        yu.backgroundColor = UIColor.clear
        yo.backgroundColor = UIColor.clear
        ra.backgroundColor = UIColor.clear
        ri.backgroundColor = UIColor.clear
        ru.backgroundColor = UIColor.clear
        re.backgroundColor = UIColor.clear
        ro.backgroundColor = UIColor.clear
        wa.backgroundColor = UIColor.clear
        wo.backgroundColor = UIColor.clear
        n.backgroundColor = UIColor.clear
        
        a.setTitleColor(kBLUENAVY, for: .normal)
        i.setTitleColor(kBLUENAVY, for: .normal)
        u.setTitleColor(kBLUENAVY, for: .normal)
        e.setTitleColor(kBLUENAVY, for: .normal)
        o.setTitleColor(kBLUENAVY, for: .normal)
        ka.setTitleColor(kBLUENAVY, for: .normal)
        ki.setTitleColor(kBLUENAVY, for: .normal)
        ku.setTitleColor(kBLUENAVY, for: .normal)
        ke.setTitleColor(kBLUENAVY, for: .normal)
        ko.setTitleColor(kBLUENAVY, for: .normal)
        sa.setTitleColor(kBLUENAVY, for: .normal)
        shi.setTitleColor(kBLUENAVY, for: .normal)
        su.setTitleColor(kBLUENAVY, for: .normal)
        se.setTitleColor(kBLUENAVY, for: .normal)
        so.setTitleColor(kBLUENAVY, for: .normal)
        ta.setTitleColor(kBLUENAVY, for: .normal)
        chi.setTitleColor(kBLUENAVY, for: .normal)
        tsu.setTitleColor(kBLUENAVY, for: .normal)
        te.setTitleColor(kBLUENAVY, for: .normal)
        to.setTitleColor(kBLUENAVY, for: .normal)
        na.setTitleColor(kBLUENAVY, for: .normal)
        ni.setTitleColor(kBLUENAVY, for: .normal)
        nu.setTitleColor(kBLUENAVY, for: .normal)
        ne.setTitleColor(kBLUENAVY, for: .normal)
        no.setTitleColor(kBLUENAVY, for: .normal)
        ha.setTitleColor(kBLUENAVY, for: .normal)
        hi.setTitleColor(kBLUENAVY, for: .normal)
        fu.setTitleColor(kBLUENAVY, for: .normal)
        he.setTitleColor(kBLUENAVY, for: .normal)
        ho.setTitleColor(kBLUENAVY, for: .normal)
        ma.setTitleColor(kBLUENAVY, for: .normal)
        mi.setTitleColor(kBLUENAVY, for: .normal)
        mu.setTitleColor(kBLUENAVY, for: .normal)
        me.setTitleColor(kBLUENAVY, for: .normal)
        mo.setTitleColor(kBLUENAVY, for: .normal)
        ya.setTitleColor(kBLUENAVY, for: .normal)
        yu.setTitleColor(kBLUENAVY, for: .normal)
        yo.setTitleColor(kBLUENAVY, for: .normal)
        ra.setTitleColor(kBLUENAVY, for: .normal)
        ri.setTitleColor(kBLUENAVY, for: .normal)
        ru.setTitleColor(kBLUENAVY, for: .normal)
        re.setTitleColor(kBLUENAVY, for: .normal)
        ro.setTitleColor(kBLUENAVY, for: .normal)
        wa.setTitleColor(kBLUENAVY, for: .normal)
        wo.setTitleColor(kBLUENAVY, for: .normal)
        n.setTitleColor(kBLUENAVY, for: .normal)
        
        AA.backgroundColor = UIColor.clear
        BB.backgroundColor = UIColor.clear
        CC.backgroundColor = UIColor.clear
        DD.backgroundColor = UIColor.clear
        EE.backgroundColor = UIColor.clear
        FF.backgroundColor = UIColor.clear
        GG.backgroundColor = UIColor.clear
        HH.backgroundColor = UIColor.clear
        II.backgroundColor = UIColor.clear
        JJ.backgroundColor = UIColor.clear
        KK.backgroundColor = UIColor.clear
        LL.backgroundColor = UIColor.clear
        MM.backgroundColor = UIColor.clear
        NN.backgroundColor = UIColor.clear
        OO.backgroundColor = UIColor.clear
        PP.backgroundColor = UIColor.clear
        QQ.backgroundColor = UIColor.clear
        RR.backgroundColor = UIColor.clear
        SS.backgroundColor = UIColor.clear
        TT.backgroundColor = UIColor.clear
        UU.backgroundColor = UIColor.clear
        VV.backgroundColor = UIColor.clear
        WW.backgroundColor = UIColor.clear
        XX.backgroundColor = UIColor.clear
        YY.backgroundColor = UIColor.clear
        ZZ.backgroundColor = UIColor.clear
    }

    func selectButton(button:UIButton,tag:Int) {
        if alphaSelect.contains(tag) {
            button.backgroundColor = UIColor.clear
            if let index = alphaSelect.index(of: tag) {
                alphaSelect.remove(at: index)
            }
        } else {
            button.backgroundColor = kMEMO_SELECT_COLOR
            alphaSelect.append(tag)
        }
    }
    
    func selectButtonWithouRemove(button:UIButton,tag:Int) {
        if alphaSelect.contains(tag) {
            //do nothing
        } else {
            button.backgroundColor = kMEMO_SELECT_COLOR
            alphaSelect.append(tag)
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onRowSelect(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            selectButtonWithouRemove(button: a, tag: a.tag)
            selectButtonWithouRemove(button: i, tag: i.tag)
            selectButtonWithouRemove(button: u, tag: u.tag)
            selectButtonWithouRemove(button: e, tag: e.tag)
            selectButtonWithouRemove(button: o, tag: o.tag)
        case 2:
            selectButtonWithouRemove(button: ka, tag: ka.tag)
            selectButtonWithouRemove(button: ki, tag: ki.tag)
            selectButtonWithouRemove(button: ku, tag: ku.tag)
            selectButtonWithouRemove(button: ke, tag: ke.tag)
            selectButtonWithouRemove(button: ko, tag: ko.tag)
        case 3:
            selectButtonWithouRemove(button: sa, tag: sa.tag)
            selectButtonWithouRemove(button: shi, tag: shi.tag)
            selectButtonWithouRemove(button: su, tag: su.tag)
            selectButtonWithouRemove(button: se, tag: se.tag)
            selectButtonWithouRemove(button: so, tag: so.tag)
        case 4:
            selectButtonWithouRemove(button: ta, tag: ta.tag)
            selectButtonWithouRemove(button: chi, tag: chi.tag)
            selectButtonWithouRemove(button: tsu, tag: tsu.tag)
            selectButtonWithouRemove(button: te, tag: te.tag)
            selectButtonWithouRemove(button: to, tag: to.tag)
        case 5:
            selectButtonWithouRemove(button: na, tag: na.tag)
            selectButtonWithouRemove(button: ni, tag: ni.tag)
            selectButtonWithouRemove(button: nu, tag: nu.tag)
            selectButtonWithouRemove(button: ne, tag: ne.tag)
            selectButtonWithouRemove(button: no, tag: no.tag)
        case 6:
            selectButtonWithouRemove(button: ha, tag: ha.tag)
            selectButtonWithouRemove(button: hi, tag: hi.tag)
            selectButtonWithouRemove(button: fu, tag: fu.tag)
            selectButtonWithouRemove(button: he, tag: he.tag)
            selectButtonWithouRemove(button: ho, tag: ho.tag)
        case 7:
            selectButtonWithouRemove(button: ma, tag: ma.tag)
            selectButtonWithouRemove(button: mi, tag: mi.tag)
            selectButtonWithouRemove(button: mu, tag: mu.tag)
            selectButtonWithouRemove(button: me, tag: me.tag)
            selectButtonWithouRemove(button: mo, tag: mo.tag)
        case 8:
            selectButtonWithouRemove(button: ya, tag: ya.tag)
            selectButtonWithouRemove(button: yu, tag: yu.tag)
            selectButtonWithouRemove(button: yo, tag: yo.tag)
        case 9:
            selectButtonWithouRemove(button: ra, tag: ra.tag)
            selectButtonWithouRemove(button: ri, tag: ri.tag)
            selectButtonWithouRemove(button: ru, tag: ru.tag)
            selectButtonWithouRemove(button: re, tag: re.tag)
            selectButtonWithouRemove(button: ro, tag: ro.tag)
        case 10:
            selectButtonWithouRemove(button: wa, tag: wa.tag)
            selectButtonWithouRemove(button: wo, tag: wo.tag)
            selectButtonWithouRemove(button: n, tag: n.tag)
        default:
            break
        }
    }
    
    @IBAction func alphabetSelected(_ sender: UIButton) {
        selectButton(button: sender, tag: sender.tag)
    }
    
    @IBAction func onSearch(_ sender: UIButton) {
        var resultArr = [String]()
        for number in alphaSelect {
            let index = alphabetDict.index(forKey: number)
            resultArr.append(alphabetDict[index!].value)
        }
        self.delegate?.onSyllabarySearch(characters:resultArr)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
