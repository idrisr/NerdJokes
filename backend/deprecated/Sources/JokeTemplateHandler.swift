//
//  JokeTemplateHandler.swift
//  NerdJokesBackend
//
//  Created by Nicholas Lash on 10/5/17.
//
//

import Foundation
import PerfectLib
import PerfectMustache
import PerfectHTTP

struct JokeTemplateHandler: MustachePageHandler {
    var values: MustacheEvaluationContext.MapType
    
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        contxt.extendValues(with: values)
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.appendBody(string: "\(error)")
                .completed(status: .internalServerError)
        }
    }
}
