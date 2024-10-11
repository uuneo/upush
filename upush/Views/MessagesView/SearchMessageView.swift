
import SwiftUI
import RealmSwift

struct SearchMessageView:View {
	@Binding var searchText:String
	
	@ObservedResults(Message.self,
					 sortDescriptor: SortDescriptor(keyPath: "createDate",
													ascending: false)) var messages
	
	var body: some View {
		LazyVStack{
			if let filterMessages = filterMessage(messages, searchText.trimmingCharacters(in: .whitespaces)) {
				Text(String(format: String(localized: "找到 %1$d 条数据"), filterMessages.count))
					.foregroundStyle(.gray)
				
					ForEach(filterMessages, id: \.id) { message in
						MessageView(message: message, searchText: searchText)
					}
				
				
			} else {
				// MARK: - 查找数据
				Text(String(format: String(localized: "找到 %1$d 条数据"), 0))
					.foregroundStyle(.gray)
			}
		}
	}
	
	func filterMessage(_ datas: Results<Message>, _ searchText:String)-> Results<Message>?{
		
		// 如果搜索文本为空，则返回原始数据
		guard !searchText.isEmpty else {
			return nil
		}
		
		return datas.filter("body CONTAINS[c] %@ OR title CONTAINS[c] %@ OR group CONTAINS[c] %@", searchText, searchText, searchText)
	}
}




