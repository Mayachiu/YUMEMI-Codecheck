//
//  SearchPresenter.swift
//  iOSEngineerCodeCheck
//
//  Created by 内山和輝 on 2022/11/16.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Foundation

protocol SearchPresenterInput {
    func searchButtonClicked(searchWord: String)
    func numberOfRowsInSection() -> Int
    func didSelectRowAt(at indexPath: IndexPath)
    func cellForRowAt(at indexPath: IndexPath)
}

protocol SearchPresenterOutput: AnyObject {
    func reloadTableView()
    func presentRepositoryViewController(selectedIndex: Int, repositories: [Repository])
    func configureRepositoryCellText(fullName: String, language: String?)
}

final class SearchPresenter {
    private weak var view: SearchPresenterOutput?
    var repositories: [Repository] = []
    var selectedIndex: Int = 0
    init(view: SearchPresenterOutput) {
        self.view = view
    }
}

extension SearchPresenter: SearchPresenterInput {
    func searchButtonClicked(searchWord: String) {
        APIClient.fetchRepository(searchWord: searchWord, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let gitHubResponse):
                self.repositories = gitHubResponse.items
                DispatchQueue.main.async {
                    self.view?.reloadTableView()
                }
            case .failure(let error):
                print(error)
            }
        })
    }

    func didSelectRowAt(at indexPath: IndexPath) {
        selectedIndex = indexPath.row
        view?.presentRepositoryViewController(selectedIndex: selectedIndex, repositories: repositories)
    }

    func numberOfRowsInSection() -> Int {
        return repositories.count
    }

    func cellForRowAt(at indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        view?.configureRepositoryCellText(fullName: repository.fullName, language: repository.language)
    }
}